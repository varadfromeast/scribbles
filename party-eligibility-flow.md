# Party eligibility flow

Source flowchart dated 10 March 2026.

## 1. Build the active GBM lists

Start with the party IDs from the Party protocol's `identifier_id` field. Build two lookup lists of `payload_partyAccountId_id` from Customer Association (CA) records where `payload_status = 'Active'` and `length(payload_identifier_id) <= 10`.

| List | Classification | GBM values |
| --- | --- | --- |
| 1 | Active, valid GBM | 0–8, 10–33, 50–59, 80 |
| 2 | Active, out-of-scope GBM | 9, 34, 35, 36, 40, 42, 79, 90 |

Ranges include both endpoints.

## 2. Check each party's own GBM

| Party ID lookup | Outcome |
| --- | --- |
| In List 1 | Eligible |
| In List 2 | Ineligible |
| In neither list | Continue to role verification |

The chart gives a terminal result for each list match. It leaves precedence unspecified if a party appears in both lists.

## 3. Verify roles for parties in neither list

Each verification requires both a matching role for the party under review and an active, valid GBM for the associated reference party or borrower.

### 3.1 P2P relationship

1. Find the party ID in any of these fields on a P2P relationship record.
   - `payload.detail.personalRelationship.personalRelationshipRelatedPartyIdentifier`
   - `payload.detail.professionalRelationship.professionalRelationshipRelatedPartyIdentifier`
   - `payload.detail.communityMembership.memberIdentifier`
2. Read the reference party ID from `payload_partyIdentifier_id` on that same relationship. This verification passes if that reference ID matches a `payload_partyAccountId_id` in List 1, the active, valid GBM list built from CA records.

### 3.2 CA account or contract membership

1. Find the party ID in either membership field for a CA contract.
   - `payload.customerAssociationType.masterContractDetails.account.accountMember.partyIdentifier`
   - `payload.customerAssociationType.masterContractDetails.account.contractMember.partyIdentifier`
2. Derive the main party ID for that contract from the record labeled `c` in the chart. Use `c.payload_identifier_id` when its length is at most 10. When it is longer than 10 and `c.payload_name` is at most 10 characters long, use `c.payload_name`.
3. Look up the derived main party ID against List 1's `payload_partyAccountId_id`. The verification passes if the main party ID is in List 1. The chart gives no further main-party ID fallback.

### 3.3 Collateral Coverage

Either of the following paths can satisfy this verification.

**Collateral Agreement path**

1. In Collateral Agreement (`cola`), select participants with `partyRoleType = 'Collateral Provider'` and read `cola.agreementParticipants.party.identifier.id`.
2. Match that participant identifier to `ca1.identifier_id` in Customer Association. The participant identifier can be an FKN or a party ID, so resolve the provider's party ID as `COALESCE(ca1.payload_partyAccountId_id, cola.agreementParticipants.party.identifier.id)`. The party under review must match the resolved provider ID.
3. Join Collateral Coverage (`colc`) on `cola.identifier_id = colc.collateralAgreementIdentifier_id`. Read the borrower FKN from `colc.party_identifier_id`. This path passes when the borrower has an active, valid GBM and the provider and borrower are different parties.

**Third Party Obligation path**

1. In Third Party Obligation (`tpo`), select participants with `tpo.participantPartyRoleType = 'Guarantor'` and read `tpo.thirdPartyObligationParticipants.party.identifier.id`.
2. Match that participant identifier to `ca1.identifier_id` in Customer Association. Resolve the guarantor's party ID as `COALESCE(ca1.payload_partyAccountId_id, tpo.thirdPartyObligationParticipants.party.identifier.id)`. The party under review must match the resolved guarantor ID.
3. Join Collateral Coverage (`colc`) on `tpo.identifier_id = colc.thirdPartyObligationIdentifier_id`. Read the borrower FKN from `colc.party_identifier_id`. This path passes when the borrower has an active, valid GBM and the guarantor and borrower are different parties.

The chart identifies the borrower FKN for both paths. It leaves the exact lookup from that FKN to the borrower's active GBM unspecified.

## 4. Return the role verification result

A party that reaches role verification is **eligible** if P2P, CA membership, or either Collateral Coverage path passes. If none passes, the party is **ineligible**.

The result boxes say “3” verifications. The connectors from P2P, CA membership, Collateral Agreement, and Third Party Obligation converge on the eligible outcome. The decision above follows those connectors and allows any of the four paths to qualify a party.
