#!/usr/bin/env python3

import argparse
import json
import logging
import os
import signal
import subprocess
import sys
import threading
import time


class MonitorController:
    def __init__(
        self,
        monitor_bus_id,
        step,
        sleep_multiplier,
        update_interval,
        emit_interval,
        log_file,
    ):
        self.monitor_bus_id = monitor_bus_id
        self.step = step
        self.sleep_multiplier = sleep_multiplier
        self.update_interval = update_interval
        self.emit_interval = emit_interval
        self.current_brightness = None
        self.target_brightness = None
        self.timer = None
        self.emit_timer = None
        self.setup_logging(log_file)
        self.start_emit_timer()

    def setup_logging(self, log_file):
        logging.basicConfig(
            filename=log_file,
            level=logging.INFO,
            format="%(asctime)s [%(levelname)s] %(message)s",
        )

    def start_emit_timer(self):
        def emit_loop():
            logging.info("Starting emit thread")
            while not self.emit_stop_event.is_set():
                self.emit_brightness()
                self.emit_stop_event.wait(self.emit_interval)
            logging.info("Emit thread stopped")

        self.emit_stop_event = threading.Event()
        self.emit_thread = threading.Thread(target=emit_loop)
        self.emit_thread.daemon = True
        self.emit_thread.start()

    def ddcutil_command(self, args, max_retries=3, retry_delay=1000):
        base_cmd = ["ddcutil", "--bus", self.monitor_bus_id]
        base_cmd += ["--noverify", "--sleep-multiplier", str(self.sleep_multiplier)]

        logging.info(f"ddcutil command: {base_cmd + args}")

        for attempt in range(max_retries):
            result = subprocess.run(
                base_cmd + args, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL
            )
            output = result.stdout.decode()
            lines_with_vcp = [line for line in output.split("\n") if "VCP" in line]
            logging.info(f"ddcutil output: {output}")
            if result.returncode == 0 and len(lines_with_vcp) > 0:
                return lines_with_vcp[0]

            logging.warning(
                f"ddcutil command failed: {result.returncode}\toutput: {result.stdout.decode('utf-8')}\tattempt: {attempt}"
            )
            time.sleep(retry_delay)

    def apply_brightness(self):
        if self.target_brightness is not None:
            self.ddcutil_command(["setvcp", "10", str(self.target_brightness)])
            self.current_brightness = self.target_brightness
            self.target_brightness = None
            logging.info(f"Applied brightness: {self.current_brightness}")
            self.emit_brightness()

    def update_brightness(self, change):
        self.set_target_brightness(change)
        self.emit_brightness()

        if self.timer is None or not self.timer.is_alive():
            self.timer = threading.Timer(self.update_interval, self.apply_brightness)
            self.timer.start()

    def set_target_brightness(self, change):
        if change == "max":
            self.target_brightness = 100
        elif change == "mid":
            self.target_brightness = 50
        elif change == "min":
            self.target_brightness = 0
        elif change in ["+", "-"]:
            if self.target_brightness is not None:
                self.target_brightness = max(
                    0,
                    min(
                        100,
                        self.target_brightness
                        + (self.step if change == "+" else -self.step),
                    ),
                )
            elif self.current_brightness is not None:
                self.target_brightness = max(
                    0,
                    min(
                        100,
                        self.current_brightness
                        + (self.step if change == "+" else -self.step),
                    ),
                )

    def initial_read_brightness(self):
        brightness = self.ddcutil_command(["-t", "getvcp", "10"])
        logging.info(f"Initial brightness return from ddcutil: {brightness}")
        if brightness and "VCP" in brightness:
            self.current_brightness = int(brightness.split(" ")[3])
        else:
            self.current_brightness = -1
        logging.info(f"Initial brightness: {self.current_brightness}")
        self.emit_brightness()

    def emit_brightness(self):
        brightness = (
            self.current_brightness
            if self.target_brightness is None
            else self.target_brightness
        )
        logging.info(
            f"emit_brightness:\tcurr: {self.current_brightness}\ttarget: {self.target_brightness}\tbrightness: {brightness}"
        )
        if not brightness:
            brightness = 0

        print(json.dumps({"percentage": brightness}), flush=True)

    def cleanup(self):
        logging.info("Cleaning up")
        if self.emit_stop_event:
            logging.info("Stopping emit thread")
            self.emit_stop_event.set()
        if self.emit_thread:
            logging.info("Waiting for emit thread to finish")
            self.emit_thread.join()
        if self.timer:
            logging.info("Cancelling timer")
            self.timer.cancel()
        logging.info("Cleanup done")


def parse_arguments():
    parser = argparse.ArgumentParser(description="Monitor Brightness Control Script")
    parser.add_argument("monitor_name", help="Name of the monitor")
    parser.add_argument("monitor_bus_id", help="Bus ID number of the monitor")
    parser.add_argument(
        "--step", type=int, default=5, help="Step size for brightness adjustment"
    )
    parser.add_argument(
        "--sleep_multiplier",
        type=float,
        default=0.03,
        help="Sleep multiplier for ddcutil",
    )
    parser.add_argument(
        "--update_interval",
        type=float,
        default=3.0,
        help="Interval to update brightness in seconds",
    )
    parser.add_argument(
        "--emit_interval",
        type=float,
        default=10.0,
        help="Interval to print out brightness in seconds",
    )
    parser.add_argument(
        "--log_file", default="monitor_control.log", help="File to log messages"
    )
    return parser.parse_args()


def signal_handler(signum, frame):
    monitor_controller.cleanup()
    logging.info("Signal received, exiting script")
    sys.exit(0)


def main():
    args = parse_arguments()
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    global monitor_controller
    monitor_controller = MonitorController(
        args.monitor_bus_id,
        args.step,
        args.sleep_multiplier,
        args.update_interval,
        args.emit_interval,
        args.log_file,
    )

    # Emit dummy reading
    monitor_controller.initial_read_brightness()

    receive_pipe = f"/tmp/waybar-ddc-cached-rx-{args.monitor_name}"
    try:
        os.unlink(receive_pipe)
    except OSError:
        if os.path.exists(receive_pipe):
            raise
    os.mkfifo(receive_pipe)

    while True:
        with open(receive_pipe, "r") as fifo:
            for command in fifo:
                command = command.strip()
                if command in ["+", "-", "max", "min", "mid"]:
                    monitor_controller.update_brightness(command)
                else:
                    logging.warning(f"Invalid command: {command}")


if __name__ == "__main__":
    main()
