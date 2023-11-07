# Address Spaces
As we have 4 different stages across dev & prod, we need 4 address spaces for each vNET.

Each stage uses /23 address mask, providing it with up to 512 IPs. We are leaving spaces between each for future expansion.

| Environment | Stage               | vNet Address Space |
| ----------- | ------------------- | ------------------ |
| Development | Dev                 | 10.85.8.0/23       |
| Production  | Canary              | 10.85.12.0/23      |
| Production  | Preview             | 10.85.14.0/23      |
| Production  | GeneralAvailability | 10.85.16.0/23      |