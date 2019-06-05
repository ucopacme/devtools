#!/bin/bash
cli_key=$(grep -v Access $i | awk -F , '{print $1}')
cli_secret=$(grep -v Access $i | awk -F , '{print $2}')
