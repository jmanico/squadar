# Squadar — Requirements

## Required Requirement Inputs
- Project purpose: A "Team Assembler UI" named Squadar that assesses and measures the skills of team members (via exams and other assessment methods), ranks each skill on a 1–10 scale, and represents the skills of multiple team members together in a radar chart.
- Primary users / actors: UNKNOWN (the notes name only "team members" as the subjects being assessed; who administers assessments or views charts is not stated)
- Core workflows: (1) Assess/measure a team member's skills, including by exam; (2) Assign or derive a 1–10 rank per skill; (3) Select multiple team members and view their skills on a shared radar chart.
- Business objects / data entities: Team member, Skill, Skill score (1–10), Exam/assessment, Radar chart view.
- External integrations: UNKNOWN
- Authentication / roles: UNKNOWN
- Regulatory or privacy constraints: UNKNOWN

## Functional Requirements

### Team Members
- **FR-1.1** The system MUST maintain a record of each team member who can be assessed, identified distinctly from all other team members.
- **FR-1.2** The system MUST allow team members to be selected individually and in groups for the purpose of skill display.

### Skills
- **FR-2.1** The system MUST maintain a set of named skills against which team members are assessed.
- **FR-2.2** The system MUST associate each team member with a score for each skill they have been assessed on.
- **FR-2.3** A skill score MUST be expressed on a scale of 1 to 10.
- **FR-2.4** The system MUST reject a skill score outside the 1–10 scale and MUST NOT record it.
- **FR-2.5** The system MUST distinguish a skill that has not been assessed for a team member from a skill scored at the lowest value.

### Assessment and Measurement
- **FR-3.1** The system MUST support assessing a team member's skill by means of an exam.
- **FR-3.2** The system MUST support at least one means of recording a skill score other than an exam. The additional means are TO BE DECIDED (see OQ-2).
- **FR-3.3** On completion of an exam, the system MUST produce a skill score on the 1–10 scale for the skill(s) the exam covers.
- **FR-3.4** The system MUST record the resulting score against the assessed team member and skill, so that it is retrievable for later display.
- **FR-3.5** The system MUST allow a team member's score for a skill to be reassessed, and after reassessment MUST use the updated score when displaying that team member's skills.

### Ranking
- **FR-4.1** The system MUST rank team members' skills on the 1–10 scale such that a higher score denotes greater assessed skill.
- **FR-4.2** The system MUST make each team member's per-skill rank visible to the user outside of the chart as well as within it.

### Radar Chart Visualization
- **FR-5.1** The system MUST display the skills of a selected team member as a radar chart, with one axis per skill and each axis scaled from 1 to 10.
- **FR-5.2** The system MUST display the skills of multiple selected team members on a single radar chart simultaneously.
- **FR-5.3** The system MUST visually distinguish each team member's series on a shared radar chart and MUST identify which series belongs to which team member.
- **FR-5.4** The radar chart MUST use the same set of skill axes for every team member shown on it, so that series are directly comparable.
- **FR-5.5** The system MUST update the radar chart to reflect the current selection of team members when that selection changes.
- **FR-5.6** When a selected team member has no score for a skill shown on the chart, the system MUST indicate the absence rather than plotting a value for it.
- **FR-5.7** When no team member is selected, the system MUST NOT display a populated radar chart and MUST indicate that a selection is required.

## Open Questions
- **OQ-1** Who are the actors? Specifically, who creates skills and exams, who administers or grades assessments, and who may view another team member's scores? No roles are named in the notes, so authorization behavior cannot be specified or tested.
- **OQ-2** What assessment methods are meant by "and more" besides exams (e.g. self-assessment, manager rating, peer review, imported evidence)? This determines FR-3.2.
- **OQ-3** How is a raw exam result converted into a 1–10 score — automatic scoring rule, manual judgement, or both? Without this, FR-3.3 cannot be tested precisely.
- **OQ-4** Are skill scores integers only, or are fractional values on the 1–10 scale permitted?
- **OQ-5** Is the skill set global to the system, defined per team, or per assessment? This affects which axes appear on a shared radar chart (FR-5.4).
- **OQ-6** Is there a concept of a "team" that groups members, or is the radar chart built from an ad-hoc selection of individuals? The product name implies team assembly, but the notes describe only selection of multiple members.
- **OQ-7** Is there an upper limit on the number of team members shown on one radar chart, and on the number of skill axes?
- **OQ-8** Should score history be retained after reassessment (FR-3.5), or only the latest value?
- **OQ-9** How do team members and skill data enter the system initially — manual entry, import, or another source?
