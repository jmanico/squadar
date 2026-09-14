# Squadar — Requirements

Fields and requirements marked **(assumed)** are not stated in the original project notes; they are
best-guess decisions taken to make the document complete and testable. Revisit them before build.

## Required Requirement Inputs
- Project purpose: A "Team Assembler UI" named Squadar that assesses and measures the skills of team members (via exams and other assessment methods), ranks each skill on a 1–10 scale, and represents the skills of multiple team members together in a radar chart.
- Primary users / actors: **(assumed)** Administrator (manages the skill catalog, exams and user accounts); Assessor (a manager or lead who runs assessments and records scores for members of their team); Team Member (takes exams and views their own scores); Viewer (read-only access to team charts).
- Core workflows: (1) Assess/measure a team member's skills, including by exam; (2) Assign or derive a 1–10 rank per skill; (3) Select multiple team members and view their skills on a shared radar chart; **(assumed)** (4) Administer the skill catalog and exams; (5) Assemble and save a team from selected members.
- Business objects / data entities: Team member, Skill, Skill score (1–10), Exam, Exam attempt, Assessment record, Team **(assumed)**, Radar chart view.
- External integrations: **(assumed)** None required. Outbound transactional email for exam invitations and account access is the only external dependency.
- Authentication / roles: **(assumed)** All users authenticate with an account before any data is shown. Roles are Administrator, Assessor, Team Member, Viewer, as described above.
- Regulatory or privacy constraints: **(assumed)** Skill scores and exam results are personal performance data about identifiable individuals. Each team member can view and export their own record, and their data can be deleted on request. No special-category or regulated data is stored.

## Functional Requirements

### Accounts and Authorization
- **FR-1.1** The system MUST require a user to authenticate before displaying any team member, score, exam or chart data.
- **FR-1.2** The system MUST assign every user exactly one role: Administrator, Assessor, Team Member or Viewer.
- **FR-1.3** Only an Administrator MUST be able to create, modify or deactivate user accounts and role assignments.
- **FR-1.4** A Team Member MUST be able to view their own skill scores and exam results, and MUST NOT be able to view another individual's scores except as part of a radar chart for a team they belong to.
- **FR-1.5** An Assessor MUST be able to view and record scores for team members on teams they are assigned to, and MUST NOT be able to record scores for team members outside those teams.
- **FR-1.6** A Viewer MUST be able to view teams, scores and charts, and MUST NOT be able to create or modify any record.
- **FR-1.7** The system MUST reject any request that the requesting user's role does not permit, and MUST report the refusal without disclosing the withheld data.

### Team Members and Teams
- **FR-2.1** The system MUST maintain a record of each team member who can be assessed, identified distinctly from all other team members.
- **FR-2.2** An Administrator MUST be able to add, edit and deactivate team members.
- **FR-2.3** The system MUST retain a deactivated team member's historical scores and MUST exclude that member from new assessments.
- **FR-2.4** The system MUST allow a named team to be created from a selection of team members, saved, and reopened later with the same membership. **(assumed)**
- **FR-2.5** A team member MUST be able to belong to more than one team. **(assumed)**
- **FR-2.6** The system MUST allow team members to be selected individually and in groups for the purpose of skill display, whether or not they belong to a saved team.

### Skill Catalog
- **FR-3.1** The system MUST maintain a single system-wide catalog of named skills against which all team members are assessed. **(assumed)**
- **FR-3.2** An Administrator MUST be able to add, rename and retire skills in the catalog.
- **FR-3.3** The system MUST reject a skill whose name duplicates an existing active skill.
- **FR-3.4** The system MUST retain existing scores for a retired skill and MUST NOT offer that skill for new assessments.

### Skill Scores
- **FR-4.1** The system MUST associate each team member with at most one current score per skill.
- **FR-4.2** A skill score MUST be an integer on a scale of 1 to 10 inclusive. **(assumed: integers only)**
- **FR-4.3** The system MUST reject a skill score that is not an integer in 1–10 and MUST NOT record it.
- **FR-4.4** The system MUST distinguish a skill that has not been assessed for a team member from a skill scored 1.
- **FR-4.5** The system MUST record, with each score, the skill, the team member, the assessment method, the assessor or exam that produced it, and the date recorded.
- **FR-4.6** The system MUST retain every previous score for a team member and skill as history, and MUST present the most recent score as the current one. **(assumed)**

### Assessment and Measurement
- **FR-5.1** The system MUST support assessing a team member's skill by means of an exam.
- **FR-5.2** The system MUST additionally support recording a skill score by assessor rating and by team-member self-assessment. **(assumed)**
- **FR-5.3** The system MUST mark each score with the method that produced it, and MUST make that method visible wherever a score is shown in detail.
- **FR-5.4** An Administrator MUST be able to define an exam, specifying the single skill it measures and its questions with their correct answers.
- **FR-5.5** An Assessor or Administrator MUST be able to assign an exam to one or more team members.
- **FR-5.6** A Team Member MUST be able to take an exam assigned to them, and MUST NOT be able to take an exam that has not been assigned to them.
- **FR-5.7** On submission of an exam, the system MUST score it automatically and convert the percentage of correct answers to a 1–10 score by dividing the percentage into ten equal bands, where 1–10% yields 1 and 91–100% yields 10. A score of 0% yields 1. **(assumed)**
- **FR-5.8** The system MUST record the resulting score against the assessed team member and the exam's skill, and MUST make it available for display immediately on submission.
- **FR-5.9** The system MUST show a submitting team member their resulting 1–10 score for the exam.
- **FR-5.10** The system MUST allow a team member to be reassessed on a skill by any supported method, and after reassessment MUST use the updated score wherever the current score is displayed, including in radar charts.
- **FR-5.11** A self-assessed score MUST be distinguishable from an assessor-rated or exam-derived score in the score detail view. **(assumed)**

### Ranking
- **FR-6.1** The system MUST rank team members' skills on the 1–10 scale such that a higher score denotes greater assessed skill.
- **FR-6.2** The system MUST make each team member's per-skill current score visible in a tabular or list form as well as within the radar chart.
- **FR-6.3** The system MUST be able to list team members ordered by their score for a chosen skill, highest first. **(assumed)**

### Radar Chart Visualization
- **FR-7.1** The system MUST display the skills of a selected team member as a radar chart, with one axis per skill and each axis scaled from 1 to 10.
- **FR-7.2** The system MUST display the skills of multiple selected team members on a single radar chart simultaneously.
- **FR-7.3** The system MUST visually distinguish each team member's series on a shared radar chart and MUST identify which series belongs to which team member.
- **FR-7.4** The radar chart MUST use the same set of skill axes for every team member shown on it, so that series are directly comparable.
- **FR-7.5** The user MUST be able to choose which skills from the catalog form the chart's axes. **(assumed)**
- **FR-7.6** The system MUST support at least 3 and at most 12 skill axes on one radar chart, and MUST report the limit when a selection falls outside it. **(assumed)**
- **FR-7.7** The system MUST support at least 6 team members on one radar chart, and MUST report the limit when more are selected. **(assumed)**
- **FR-7.8** The system MUST update the radar chart to reflect the current selection of team members and skills whenever that selection changes.
- **FR-7.9** When a selected team member has no score for a skill shown on the chart, the system MUST indicate the absence rather than plotting a value for it.
- **FR-7.10** When no team member is selected, the system MUST NOT display a populated radar chart and MUST indicate that a selection is required.
- **FR-7.11** The user MUST be able to show or hide an individual team member's series on a shared chart without changing the underlying selection. **(assumed)**

### Data Entry and Portability
- **FR-8.1** An Administrator MUST be able to create team members and skills through the user interface. **(assumed)**
- **FR-8.2** An Administrator MUST be able to import team members and skills in bulk from a delimited file, and the system MUST report, per row, any row it rejected and why. **(assumed)**
- **FR-8.3** A team member MUST be able to export their own complete skill and exam record in a machine-readable format. **(assumed)**
- **FR-8.4** An Administrator MUST be able to delete a team member's personal data on request, and after deletion the system MUST NOT display that member or their scores in any chart or list. **(assumed)**

### Non-Functional Requirements
- **NFR-9.1** A radar chart for the maximum supported selection (FR-7.6, FR-7.7) MUST render within 2 seconds of the selection being confirmed, measured at the 95th percentile. **(assumed)**
- **NFR-9.2** Exam submissions MUST be scored and the result shown within 5 seconds of submission. **(assumed)**
- **NFR-9.3** The system MUST support at least 1,000 team members and 100 skills without breaching NFR-9.1. **(assumed)**
- **NFR-9.4** The radar chart MUST convey each team member's series by a means other than color alone, so that it remains readable without color discrimination. **(assumed)**
- **NFR-9.5** All user-facing screens MUST be operable by keyboard alone. **(assumed)**
- **NFR-9.6** The system MUST record an audit entry for every score created, changed or deleted, capturing who made the change and when, retrievable by an Administrator. **(assumed)**
- **NFR-9.7** Exam answer keys MUST NOT be retrievable by a Team Member or Viewer at any point, including during or after an exam attempt. **(assumed)**

### Unit Testing
- **UT-10.1** Build 10 fake users with 10 different skills levels so we can rapidly test the entire system over and over with each build step.
- 
## Open Questions
- **OQ-1** Are the assumed roles correct, and in particular may a Team Member see peers' individual scores outside a shared chart? FR-1.4 currently says no.
- **OQ-2** Is the assumed exam-to-score conversion (FR-5.7) acceptable, or should exams carry per-question weights, a pass threshold, or a manual review step?
- **OQ-3** Should self-assessed scores count toward the current score shown on a radar chart, or only be shown alongside an assessor- or exam-derived score?
- **OQ-4** Do skill scores expire or decay if a member has not been reassessed for some period, and if so after how long?
- **OQ-5** Are the assumed chart limits (3–12 skills, 6 members) the right sizes for the intended teams?
- **OQ-6** Does "assembling a team" involve recommending members based on a target skill profile, or only saving a manually chosen set as in FR-2.4?
