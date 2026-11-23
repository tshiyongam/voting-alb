#!/bin/bash
# EC2 user-data script to install the application and start gunicorn.
# The Polls table already exists in Amazon DynamoDB. This script does not
# create it.
#
# Paste this file into the User data field of the launch template.
# Cloud-init runs it once as root on first boot of each instance.
#
# All output is saved to /var/log/cloud-init-output.log.

# Exit on error, undefined variable, or failure in a pipeline.
set -euo pipefail

##############################################################################
##############################################################################
# CHANGE REPO_URL BELOW: REPLACE YOUR_GITHUB_USERNAME WITH YOUR GITHUB
# USERNAME. DO NOT CHANGE THE REPOSITORY NAME (voting-alb).
##############################################################################
##############################################################################
REPO_URL="https://github.com/tshiyongam/voting-alb.git"

APP_DIR=/home/ec2-user/voting-alb

yum install -y python3.12 git

git clone "$REPO_URL" "$APP_DIR"
cd "$APP_DIR"

# Use python3.12 instead of python3 to ensure we use the correct version of Python
python3.12 -m venv .venv
.venv/bin/pip install --upgrade pip
.venv/bin/pip install -r requirements.txt
.venv/bin/pip install -e .

# This script runs as root, but the app runs as ec2-user. Change ownership
# to ec2-user for all files created in the previous steps.
chown -R ec2-user:ec2-user "$APP_DIR"

cp deploy/voting.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now voting.service
