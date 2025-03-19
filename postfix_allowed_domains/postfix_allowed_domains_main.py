#!/usr/bin/python
# coding: utf-8

import os
import public
import subprocess  # Import subprocess for running shell commands

class postfix_allowed_domains_main:
    allowed_domains_file = "/etc/postfix/allowed_domains"

    # Retrieve allowed domains directly from the file
    def get_domains(self, args):
        if not os.path.exists(self.allowed_domains_file):
            return public.returnMsg(False, "Allowed domains file does not exist.")

        try:
            with open(self.allowed_domains_file, "r") as file:
                domains = []
                for line in file:
                    line = line.strip()
                    if line and "OK" in line:  # Only take valid domain lines
                        domain = line.split()[0]  # Extract the domain name
                        domains.append(domain)

            return {"domains": domains} if domains else {"domains": []}

        except Exception as e:
            return public.returnMsg(False, f"Error reading file: {str(e)}")

    # Add a domain to the allowed_domains file
    def add_domain(self, args):
        domain = args.domain.strip()
        if not domain:
            return public.returnMsg(False, "Invalid domain format.")

        entry = f"{domain} OK\n"

        # Check if the domain already exists in the file
        if os.path.exists(self.allowed_domains_file):
            with open(self.allowed_domains_file, "r") as file:
                existing_domains = file.readlines()
                if any(line.strip() == entry.strip() for line in existing_domains):
                    return public.returnMsg(False, "Domain already exists.")

        # Append the new domain
        with open(self.allowed_domains_file, "a") as file:
            file.write(entry)

        # Compile the file with postmap
        subprocess.run(["sudo", "postmap", self.allowed_domains_file], check=True)
        subprocess.run(["sudo", "systemctl", "restart", "postfix"], check=True)

        return public.returnMsg(True, f"Domain {domain} added successfully!")

    # Remove a domain from the allowed_domains file
    def remove_domain(self, args):
        domain = args.domain.strip()
        if not domain:
            return public.returnMsg(False, "Invalid domain format.")

        if not os.path.exists(self.allowed_domains_file):
            return public.returnMsg(False, "Allowed domains file does not exist.")

        try:
            with open(self.allowed_domains_file, "r") as file:
                lines = file.readlines()

            new_lines = [line for line in lines if not line.startswith(f"{domain} OK")]

            if len(new_lines) == len(lines):
                return public.returnMsg(False, "Domain not found in allowed list.")

            # Rewrite the file with the updated list
            with open(self.allowed_domains_file, "w") as file:
                file.writelines(new_lines)

            # Recompile the file with postmap
            subprocess.run(["sudo", "postmap", self.allowed_domains_file], check=True)
            subprocess.run(["sudo", "systemctl", "restart", "postfix"], check=True)

            return public.returnMsg(True, f"Domain {domain} removed successfully!")

        except Exception as e:
            return public.returnMsg(False, f"Error updating file: {str(e)}")
