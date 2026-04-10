# SSH Hardening Notes

The SSH hardening work was performed on `srv-web`, which acts as the managed host on Site B.

A dedicated administrator account called `adminX` was created for the lab. The intention was to avoid relying on shared or generic accounts and to make the access policy explicit in the configuration.

The client-side key was generated on `client-kali` using Ed25519, then copied to the server for `adminX`. Key-based access was tested before password login was disabled. This sequencing mattered because it reduced the risk of locking out remote administration while modifying the daemon settings.

The final SSH policy was based on the following decisions:

- do not allow password-based authentication
- do not allow direct root login
- allow only the dedicated admin account
- keep the authentication window short
- reduce repeated authentication attempts
- ensure that both successful and failed attempts remain visible in logs

The main configuration file was not the only place where this policy had to be applied. During validation, password login was still accepted even though the primary SSH configuration looked correct. The cause was a cloud-init include file that re-enabled password authentication. Correcting that override was necessary before the hardening became effective in practice.

From an operational point of view, the SSH part of the lab was validated by three checks:
- successful key login as `adminX`
- failed password-only login
- failed root login

This was enough to show that the final access path was narrower, more controlled, and more auditable than the default one.
