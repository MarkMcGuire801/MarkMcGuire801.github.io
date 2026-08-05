export type SkillGroup = {
  category: string;
  note?: string;
  bands: { label?: string; items: string[] }[];
};

export const skills: SkillGroup[] = [
  {
    category: "Frameworks & GRC",
    note: "Currently studying",
    bands: [{ items: ["NIST RMF", "NIST SP 800-53 (Rev 5)", "CMMC 2.0", "FedRAMP", "FISMA", "STIG Implementation"] }],
  },
  {
    category: "Microsoft Cloud & Security",
    bands: [{ items: ["Azure", "Sentinel", "Defender for Identity/Endpoint", "Entra / Identity", "Intune", "Purview", "Exchange", "SharePoint", "Teams Admin Center"] }],
  },
  {
    category: "Systems",
    bands: [{ items: ["Windows 10/11", "Active Directory", "Group Policy", "Sysmon"] }],
  },
  {
    category: "Security Tools",
    bands: [
      { label: "Familiar", items: ["Wireshark", "OpenVAS (GreenBone)", "Zenmap / NMap", "Syslog", "RDP"] },
      { label: "Some use", items: ["Wazuh", "Metasploit", "Burp Suite", "BloodHound", "GoPhish", "Ettercap", "Hydra", "John the Ripper", "DVWA"] },
    ],
  },
  {
    category: "Systems & Infrastructure",
    bands: [
      { label: "Familiar", items: ["Hyper-V", "PDQ Inventory", "PDQ Deploy", "Track-IT (Ticketing)", "SCCM"] },
      { label: "Some use", items: ["ProxMox"] },
    ],
  },
  {
    category: "Networking",
    bands: [
      { label: "Protocols & routing", items: ["OSPF", "eBGP", "HSRP", "BGP Path Selection", "DHCP Relay", "NAT", "NTP", "SSH", "Floating Static Routes", "Route Summarization"] },
      { label: "Switching & VLANs", items: ["Rapid PVST+", "STP", "VLANs", "802.1q Trunking", "Inter-VLAN Routing", "Layer 3 Switching", "SVIs"] },
      { label: "Security", items: ["IPSec VPN", "IKE", "ACLs", "DHCP Snooping", "Dynamic ARP Inspection", "WPA2", "Network Segmentation", "Access Control", "Management Plane Security", "Guest Network Isolation", "Perimeter Security"] },
      { label: "Design & documentation", items: ["Hierarchical Network Design", "Collapsed Core Architecture", "Redundancy Design", "IP Addressing", "VLSM", "Subnetting", "Network Documentation", "Network Troubleshooting"] },
      { label: "Hardware & tools", items: ["Cisco IOS", "Cisco Catalyst 3650", "Cisco ISR Routers", "Packet Tracer", "Wireless Network Configuration"] },
    ],
  },
  {
    category: "Linux",
    bands: [{ label: "Some use", items: ["LPI Linux Essentials", "Ubuntu", "Kali Linux", "Apache", "LAMP Stack"] }],
  },
  {
    category: "Programming & Automation",
    note: "Most → least familiar",
    bands: [{ items: ["Python", "HTML", "CSS", "SQL", "PowerShell", "Bash / Shell", "Git / GitHub", "Ansible", "Terraform", "Docker"] }],
  },
  {
    category: "General",
    bands: [{ items: ["Customer Support", "Verbal & Written Communication", "Technical Documentation", "Auditing", "Staff Training", "Asset Inventory Management", "Change Management", "Vendor Management"] }],
  },
];
