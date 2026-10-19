@echo off

set RULE_NAME=NVStream

rem Delete the rule
netsh advfirewall firewall delete rule name=%RULE_NAME%
