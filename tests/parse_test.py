import unittest
import sys
sys.path.append('../hacklog')
from parse import Parser
from entities import *
import re

parse = Parser()

class ParserTests(unittest.TestCase):

    #parse = Parser()
    def test_starting_out(self):
        self.assertEqual(1, 1)

    def test_parse_line_success(self):
        sysLogMessage = SyslogMsg("<14>sshd[3070]: Accepted publickey for kantselovich from 10.42.10.2 port 2005 ssh2\x00", "192.168.56.1")
        self.assertIsInstance(parse.parseLogLine(sysLogMessage), EventLog)

    def test_parse_line_failure(self):
        sysLogMessage = SyslogMsg("<14>sshd[3070]: pam_unix(sshd:auth): authentication failure; login= uid=0 euid=0 tty=ssh ruser= rhost=10.42.10.22 user=msacks", "192.168.56.1")
        self.assertIsInstance(parse.parseLogLine(sysLogMessage), EventLog)

    def test_parse_windows_Logs(self):
        sysLogMessage = SyslogMsg("Oct 10 14:26:09 USERNAME-DEV-VM Security-Auditing: 4624: AUDIT_SUCCESS An account was successfully logged on. Subject: Security ID: S-1-5-18 Account Name: USERNAME-DEV-VM$ Account Domain: WORKGROUP Logon ID: 0x3e7 Logon Type: 2 New Logon: Security ID: S-1-5-21-1223658549-3667468651-3388596622-1001 Account Name: developer Account Domain: username-dev-vm Logon ID: 0x8b32b5 Logon GUID: {00000000-0000-0000-0000-000000000000} Process Information: Process ID: 0x820 Process Name: C:\Windows\System32\winlogon.exe Network Information: Workstation Name: USERNAME-DEV-VM Source Network Address: 127.0.0.1 Source Port: 0 Detailed Authentication Information: Logon Process: User32 Authentication Package: Negotiate Transited Services: - Package Name (NTLM only): - Key Length: 0 This event is generated when a logon session is created. It is generated on the computer that was accessed. The subject fields indicate the account on the local system which requested the logon. This is most commonly a service such as the Server service, or a local process such as Winlogon.exe or Services.exe. The logon type field indicates the kind of logon that occurred. The most common types are 2 (interactive) and 3 (network). The New Logon fields indicate the account for whom the new logon was created, i.e. the account that was logged on. The network fields indicate where a remote logon request originated. Workstation name is not always available and may be left blank in some cases. The authentication information fields provide detailed information about this specific logon request. - Logon GUID is a unique identifier that can be used to correlate this event with a KDC event. - Transited services indicate which intermediate services have participated in this logon request. - Package name indicates which sub-protocol was used among the NTLM protocols. - Key length indicates the length of the generated session key. This will be 0 if no session key was requested.", "192.168.56.1")
        self.assertIsInstance(parse.parseLogLine(sysLogMessage), EventLog)

def main():
    unittest.main()

if __name__ == "__main__":
    main()

