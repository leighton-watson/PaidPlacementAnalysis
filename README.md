# PaidPlacementAnalysis
Economic modelling of the financial implications of university training and unpaid placements on workers in healthcare and education workforces

This repository contains MATLAB code for modelling the salary, superannuation, and student loan balances for (a) essential services that require university qualifications and unpaid placements (teachers, nurses, midwives, and social workers) and (b) essential services that do not require university qualifications and have paid training (police and firefighters). This work is focused on Aotearoa New Zealand.

Salary scales are taken from collective employment agreements for each profession. 
* Teachers: [Primary teachers collective agreement](https://www.nzeiteriuroa.org.nz/assets/downloads/Primary-Teachers-Collective-Agreement-2023-2025-October-2023-PTCA-variation-Clean-copy-002.pdf), 3 July 2023 - 2 July 2025 (varied on 30 October 2023). The salary information is taken from Section 3.2, Base Salary Scale, Unified Base Salary Scale for Trained Teachers, page 13. Rates effective from
2 December 2024. Start at step 1 (the same as step 2) and move up one step each year to a maximum of step 11. 
* Nurses: [Te Whatu Ora - Health New Zealand and NZNO Nursing and Midwifery Collective Agreement](https://www.nzno.org.nz/Portals/0/Files/Documents/Groups/Health%20Sectors/DHB%20MECA/2023-07-18_HNZ_offer.pdf) 17 July 2023. The salary information is from Appendix 1 for **Registered Nurses** (page 11). Rates effective from 1 April 2024. Start at step 1 and move up one step each year to step 7 (which is the same as step 8).
* Midwives: [Te Whatu Ora - Health New Zealand and NZNO Nursing and Midwifery Collective Agreement](https://www.nzno.org.nz/Portals/0/Files/Documents/Groups/Health%20Sectors/DHB%20MECA/2023-07-18_HNZ_offer.pdf) 17 July 2023. The salary information is from Appendix 1 for **Registered Midwives** (pages 13 and 14). Rates effective from 1 April 2024. Start at step 1 and move up one step each year to step 7.
* Social Workers: [Social Worker](https://www.publicservice.govt.nz/system/public-service-people/pay-gaps-and-pay-equity/extension-of-pay-equity). Start at step 3 and move up one step each year until step 10.
* Police. [New Zealand Police Constabulary Collective Employment Agreement](https://www.policeassn.org.nz/#/). 
     * Salaries are taken from band G in the 1 July 2022 and 30 June 2023 remuneration scales. A new police officer starts at step 0 and moves up one step each year until they reach step 20, which is the top of the scale. We assume no promotion to higher bands. Band G is for constables, which represent 57% of the constabulary staff. 
    * The salaries listed in the police collective agreement are *total remuneration* and include salary, insurance subsidy ($208), physical competence (PCT) payment ($863), and the employer superannuation subsidy (10.184% of salary).
* Firefighters: [Collective Employment Agreement](https://www.nzpfu.org.nz/resources/). The salary information is from [Appendix 1](https://www.nzpfu.org.nz/media/website_pages/resources/Appendix-One-Final-TOS-to-pdf.pdf). Rates are for 2023/2024.
    * Year 1 is at the *Trainee Firefighter - ND* rate.
    * Years 2 and 3 are at the *Firefighter - ND* rate.
    * Years 4 and 5 are at the *Qualified Firefighter - ND* rate.
    * Years 6 and above are at the *Senior Firefighters - ND* rate.

The salary information in this repository is up-to-date as of June 2024. The salary information will change as collective employment agreements are renegotiated. For the most up-to-date information, contact the unions:
* Teachers: [New Zealand Education Institute (NZEI) Te Riu Roa](https://www.nzeiteriuroa.org.nz/)
* Nurses: [New Zealand Nurses Organisation](https://www.nzno.org.nz/)
* Midwives: [New Zealand College of Midwives](https://meras.midwife.org.nz/)
* Social Workers: [Aotearoa New Zealand Association of Social Workers](https://www.anzasw.nz/)
* Police: [New Zealand Police Association](https://www.policeassn.org.nz/#/)
* Firefighters: [New Zealand Professional Firefighters Union](https://www.nzpfu.org.nz/)

### Who do I contact? ###
Leighton Watson: leighton.watson@canterbury.ac.nz
