# Publication Request Writeup for draft-ietf-httpbis-cache

(1) What type of RFC is being requested (BCP, Proposed Standard, Internet Standard, Informational, Experimental, or Historic)? Why is this the proper type of RFC? Is this type of RFC indicated in the title page header?

This document is intended for the standards track.  As a revision to a
standards-track document (RFC 7234), this is appropriate.

Full Standard is probably an appropriate target status for the document.  If
any set of documents is ready for that status, then HTTP qualifies.

(2) The IESG approval announcement includes a Document Announcement Write-Up. Please provide such a Document Announcement Write-Up. Recent examples can be found in the "Action" announcements for approved documents. The approval announcement contains the following sections:

Technical Summary:

This document defines HTTP caches and the associated header fields that
control cache behavior or indicate cacheable response messages.

Working Group Summary:

This document was primarily driven by the editors.  A non-trivial amount of
work was involved in updating and refining documents (RFC 723x) that were
already in a good state.  Working group engagement was good, though lighter
for this document than others.

Document Quality:

This is a very widely implemented protocol.

As this is a revision, with only minor changes, the usual review procedures do
no apply to the document.

The main improvements here are to validate aspects of the protocol
  documentation based on what has been deployed.  Changes are largely the
result of extensive testing (see https://cache-tests.fyi/ for details), which
validated many unchanged portions and justified the small number of changes
that were included.

Personnel:

Martin Thomson is shepherd; Francesca Palombini is area director.

(3) Briefly describe the review of this document that was performed by the Document Shepherd. If this version of the document is not ready for publication, please explain why the document is being forwarded to the IESG.

The document is clean in idnits and validates according to the rigorous build
processes used by the editors.  This includes abnf validation for the formal
language in the document, plus the examples.

(4) Does the document Shepherd have any concerns about the depth or breadth of the reviews that have been performed?

Reviews seem adequate.  Note that additional review of these documents was
necessary as a part of developing HTTP/3.

(5) Do portions of the document need review from a particular or from broader perspective, e.g., security, operational complexity, AAA, DNS, DHCP, XML, or internationalization? If so, describe the review that took place.

No additional review seems necessary.

(6) Describe any specific concerns or issues that the Document Shepherd has with this document that the Responsible Area Director and/or the IESG should be aware of? For example, perhaps he or she is uncomfortable with certain parts of the document, or has concerns whether there really is a need for it. In any event, if the WG has discussed those issues and has indicated that it still wishes to advance the document, detail those concerns here.

No specific concerns.

(7) Has each author confirmed that any and all appropriate IPR disclosures required for full conformance with the provisions of BCP 78 and BCP 79 have already been filed. If not, explain why?

Yes, the authors have confirmed that they are in compliance.

(8) Has an IPR disclosure been filed that references this document? If so, summarize any WG discussion and conclusion regarding the IPR disclosures.

Datatracker doesn't list any disclosures on this or its predecessor.

(9) How solid is the WG consensus behind this document? Does it represent the strong concurrence of a few individuals, with others being silent, or does the WG as a whole understand and agree with it?

The working group has engaged well.

(10) Has anyone threatened an appeal or otherwise indicated extreme discontent? If so, please summarise the areas of conflict in separate email messages to the Responsible Area Director. (It should be in a separate email because this questionnaire is publicly available.)

No drama to report.

(11) Identify any ID nits the Document Shepherd has found in this document. (See http://www.ietf.org/tools/idnits/ and the Internet-Drafts Checklist). Boilerplate checks are not enough; this check needs to be thorough.

idnits complains about things that are non-issues.  I have reviewed the
document, but have not followed the checklist closely (that page has broken
formatting and is clearly out of date).

(12) Describe how the document meets any required formal review criteria, such as the MIB Doctor, YANG Doctor, media type, and URI type reviews.

Those reviews should have passed for its predecessor.

(13) Have all references within this document been identified as either normative or informative?

I have carefully reviewed this and the references are correct.

(14) Are there normative references to documents that are not ready for advancement or are otherwise in an unclear state? If such normative references exist, what is the plan for their completion?

This is part of a small cluster of three documents advancing simultaneously.
No other normative references to in-progress work are made.

(15) Are there downward normative references references (see RFC 3967)? If so, list these downward references to support the Area Director in the Last Call procedure.

No downrefs.

(16) Will publication of this document change the status of any existing RFCs? Are those RFCs listed on the title page header, listed in the abstract, and discussed in the introduction? If the RFCs are not listed in the Abstract and Introduction, explain why, and point to the part of the document where the relationship of this document to the other RFCs is discussed. If this information is not in the document, explain why the WG considers it unnecessary.

This updates RFC 7234 and that is in header, abstract, and introduction
according to established standards.

(17) Describe the Document Shepherd's review of the IANA considerations section, especially with regard to its consistency with the body of the document. Confirm that all protocol extensions that the document makes are associated with the appropriate reservations in IANA registries. Confirm that any referenced IANA registries have been clearly identified. Confirm that newly created IANA registries include a detailed specification of the initial contents for the registry, that allocations procedures for future registrations are defined, and a reasonable name for the new registry has been suggested (see RFC 8126).

The IANA considerations are clear and accurate.

(18) List any new IANA registries that require Expert Review for future allocations. Provide any public guidance that the IESG would find useful in selecting the IANA Experts for these new registries.

No new registries have been created.

(19) Describe reviews and automated checks performed by the Document Shepherd to validate sections of the document written in a formal language, such as XML code, BNF rules, MIB definitions, YANG modules, etc.

If this question were able to be removed from this template, it would be good.
Any document that isn't automating these checks as part of its production
shouldn't get to the point of requesting publication.

All the relevant checks on this document have been automated.

(20) If the document contains a YANG module, has the module been checked with any of the recommended validation tools (https://trac.ietf.org/trac/ops/wiki/yang-review-tools) for syntax and formatting validation? If there are any resulting errors or warnings, what is the justification for not fixing them at this time? Does the YANG module comply with the Network Management Datastore Architecture (NMDA) as specified in RFC8342?

YANG!
