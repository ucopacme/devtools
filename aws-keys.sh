#!/bin/bash
cli_key=$(grep -v Access $1 | awk -F , '{print $1}')
cli_secret=$(grep -v Access $1 | awk -F , '{print $2}')
echo export cli_key=$cli_key
echo export cli_secret=$cli_secret
