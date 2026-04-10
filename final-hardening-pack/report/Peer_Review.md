# Peer Review

## Project reviewed
Final Hardening Pack

## General impression

The project is well organized and easy to follow overall. The folder structure makes sense, and it is clear that the team tried to build something practical rather than just writing a report. The idea of linking claims to tests and evidence is a good approach and makes the work look more professional.

At the moment, the strongest part of the project is the regression suite, because it gives a quick way to check whether the main controls still work after changes. That is useful and fits the objective of the final workshop.

## What works well

The repository is structured in a logical way. It is easy to find the architecture files, control areas, tests, and report documents. The separation between technical evidence and executive-level writing is also a good point.

The regression scripts are a strong part of the submission. They cover the main areas of the project: firewall behavior, TLS, remote access, and detection. The fact that the tests can fail and show drift is actually a positive thing, because it proves the checks are meaningful.

The project also shows good effort in turning the earlier TDs into one final deliverable instead of leaving them as separate lab exercises.

## Points to improve

Some parts still need to be aligned better. In a few places, the report wording sounds like the intended policy, while the latest test outputs show that the deployed state is different. The claims should match exactly what the evidence proves.

A second point is that some evidence is still incomplete. For example, detection traffic is generated, but the corresponding IDS alert should be saved and referenced clearly in the report. The same applies to firewall or service-state evidence when a regression fails.

There are also some assumptions that should be written more clearly, especially for SSH access, valid users, keys, and whether VPN access is required before some tests can pass.

## Reproducibility

The project is mostly reproducible. The scripts are in the right place, the outputs are stored by timestamp, and the overall method is clear. Still, a new person trying to run everything might need a bit more context about which account to use, what services must already be running, and where to collect logs from.

Adding a short prerequisites section would improve this a lot.

## Maintainability

The project looks maintainable because the structure is clean and the tests are separated by topic. That said, before final submission, it would be good to check that there are no empty files, placeholder sections, or references to evidence that does not exist yet.

A final cleanup pass would make the whole pack stronger.

## Conclusion

Overall, this is a solid project with a good technical direction. The regression suite is probably the best part because it makes the hardening work measurable. The main thing left is to make sure the claims, evidence, and actual system state all match each other exactly.

## Recommended next steps

- update the claims table so it matches the latest test results exactly
- add the missing IDS log or alert evidence
- document SSH/VPN assumptions more clearly
- remove empty or unfinished files before submission
- rerun the full regression suite after final fixes
