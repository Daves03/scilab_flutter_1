# AR Experiment Grading Rubric and Deduction Guide

## 1. Purpose

SciLab automatically grades each completed AR experiment out of **100 points**. The grade measures laboratory safety, performance of the procedure, production of the expected result, and scientific understanding.

The final grade contains four equally weighted categories:

| Category | Maximum points |
|---|---:|
| PPE and Safety | 25 |
| Procedure, Sequence, and Equipment Handling | 25 |
| Experimental Results | 25 |
| Scientific Understanding | 25 |
| **Total** | **100** |

Each category uses the same performance ranges:

| Score | Performance range | General meaning |
|---:|---|---|
| **25–18** | Proficient | The student performed the criterion correctly or with only minor errors. |
| **17–10** | Developing | The student demonstrated partial competency but made several errors or needed guidance. |
| **9–2** | Beginning | The student demonstrated limited competency and needs substantial assistance. |
| **0** | No Evidence | The student did not demonstrate the criterion or produced no assessable result. |

Teachers can configure each experiment's PPE choices, correct selections, and
5–10 post-experiment quiz questions in the teacher web portal. The app uses the
settings loaded before the PPE check for that entire run. See
[Teacher-editable experiment assessments](TEACHER_EXPERIMENT_ASSESSMENTS.md).

The **0-point level is recorded separately** because it represents no demonstrated evidence. In the student result table, it is displayed with the lowest performance range.

---

## 2. Complete Rubric

| Category | Assessment details | 25–18 points: Proficient | 17–10 points: Developing | 9–2 points: Beginning |
|---|---|---|---|---|
| **PPE AND SAFETY** | Assesses the student's first-attempt selection of required personal protective equipment. The system identifies missing required PPE and unnecessary PPE. | All or nearly all required PPE was selected. Safety choices were appropriate, with no error or only a minor error. | Some required PPE was missing or unnecessary PPE was selected. The student needed safety reminders before continuing. | Many required PPE items were missing or inappropriate items were selected, showing unsafe preparation and limited recognition of laboratory hazards. |
| **PROCEDURE, SEQUENCE, AND EQUIPMENT HANDLING** | Assesses whether steps were performed in the correct order and whether the correct materials, apparatus, containers, and connections were used. | Steps were completed in the correct or nearly correct order. Equipment was selected, handled, and connected properly, with few or no detected errors. | Several sequence or equipment-handling errors occurred. The procedure was partly correct but required guidance or correction. | Frequent sequence and equipment errors occurred, showing limited ability to perform the procedure safely, accurately, and independently. |
| **EXPERIMENTAL RESULTS** | Assesses whether the expected reaction, observation, measurement, or final product was produced. | The expected scientific outcome was produced clearly and accurately and matched the experiment objective. | The expected outcome was partly produced, but observations, measurements, or the final result were incomplete or inaccurate. | The expected outcome was weak, incorrect, or not successfully produced. |
| **SCIENTIFIC UNDERSTANDING** | Assesses understanding through a minimum of 5 and a maximum of 10 automatically graded post-experiment questions. | The student demonstrates strong understanding of the scientific concept and correctly explains the experiment and its outcome. | The student demonstrates partial understanding. Some answers are correct, but important concepts or explanations remain unclear. | The student demonstrates limited understanding and cannot correctly explain the scientific concept or experimental outcome. |

---

## 3. PPE and Safety Grading

### 3.1 What is assessed

The system checks the student's **first PPE submission** for:

- required PPE selected correctly;
- required PPE that was missed; and
- PPE selected even though it was not required for the experiment.

The first attempt is graded to measure the student's independent recognition of laboratory hazards. If the first attempt is incorrect, the student must correct the selection before entering the experiment, but the original first-attempt score remains.

### 3.2 Formula

```text
PPE score = round((correct required PPE / total required PPE) × 25)
            − number of unnecessary PPE items
```

The score is constrained to **0–25 points**.

The deduction shown to the student is:

```text
PPE deduction = 25 − PPE score
```

### 3.3 Example with four required PPE items

| First-attempt performance | Calculation | Earned | Deduction | Range |
|---|---:|---:|---:|---|
| Four correct, no unnecessary PPE | `round(4/4 × 25)` | 25 | 0 | Proficient |
| Three correct, no unnecessary PPE | `round(3/4 × 25)` | 19 | 6 | Proficient |
| Three correct and one unnecessary item | `19 − 1` | 18 | 7 | Proficient |
| Two correct, no unnecessary PPE | `round(2/4 × 25)` | 13 | 12 | Developing |
| One correct, no unnecessary PPE | `round(1/4 × 25)` | 6 | 19 | Beginning |
| No required PPE selected | `round(0/4 × 25)` | 0 | 25 | No Evidence |

### 3.4 Student feedback

The completion result identifies:

- the first-attempt score out of 25;
- total points deducted;
- names of missing PPE items; and
- names of unnecessary PPE items.

Example:

```text
Missing: Safety goggles.
Unnecessary: Face mask / respirator.
Earned: 18/25. Deduction: -7 points.
```

---

## 4. Procedure, Sequence, and Equipment Handling Grading

### 4.1 What is assessed

This combined category checks:

- whether actions were completed in the required scientific order;
- whether an activator or final step was used too early;
- whether the correct material or chemical was used;
- whether the correct apparatus or container was used;
- whether equipment was connected correctly; and
- whether an action received from the AR scene matched a recognized experimental step.

### 4.2 Deductions

| Detected error | Deduction per error |
|---|---:|
| Sequence error | **-5 points** |
| Equipment-handling error | **-2 points** |

### 4.3 Formula

```text
Procedure, sequence, and equipment score =
25 − (sequence errors × 5) − (equipment errors × 2)
```

The score is constrained to **0–25 points**. Deductions cannot produce a negative category score.

### 4.4 Examples

| Sequence errors | Equipment errors | Calculation | Earned | Deduction | Range |
|---:|---:|---:|---:|---:|---|
| 0 | 0 | `25` | 25 | 0 | Proficient |
| 1 | 0 | `25 − 5` | 20 | 5 | Proficient |
| 1 | 1 | `25 − 5 − 2` | 18 | 7 | Proficient |
| 0 | 4 | `25 − 8` | 17 | 8 | Developing |
| 2 | 0 | `25 − 10` | 15 | 10 | Developing |
| 1 | 4 | `25 − 5 − 8` | 12 | 13 | Developing |
| 3 | 1 | `25 − 15 − 2` | 8 | 17 | Beginning |
| 4 | 1 | `25 − 20 − 2` | 3 | 22 | Beginning |
| 5 | 0 | `25 − 25` | 0 | 25 | No Evidence |

### 4.5 Student feedback

The completion result displays both error counts, the deduction rule, the earned score, and the total deduction.

Example:

```text
1 sequence error and 1 equipment error were detected.
Sequence errors deduct 5 points and equipment errors deduct 2 points.
Earned: 18/25. Deduction: -7 points.
```

---

## 5. Experimental Results Grading

### 5.1 What is assessed

The expected outcome depends on the experiment and may include:

- a visible chemical reaction;
- a required color change;
- formation of a precipitate;
- production or identification of a gas;
- a correct measurement;
- completion of an electrical connection or observable effect; or
- another experiment-specific scientific outcome.

### 5.2 Performance ranges

| Score | Grading basis | Typical deduction |
|---:|---|---:|
| **25–18** | Expected result produced clearly and accurately. Observations or measurements match the scientific objective. | 0–7 points |
| **17–10** | Result partly produced. Some required observations or measurements are incomplete or inaccurate. | 8–15 points |
| **9–2** | Result is weak, substantially incorrect, or unsuccessful. | 16–23 points |
| **0** | No valid or assessable result was produced. | 25 points |

### 5.3 Current automatic scoring behavior

In the current AR completion flow, the experiment sends a successful completion event after the expected terminal outcome is produced. That event awards **25/25 points** for Experimental Results.

The partial and unsuccessful bands are defined in the rubric and displayed in the table. To award a score from 1–24 automatically, the Unity experiment must send additional result-quality data, such as incomplete outcome, incorrect measurement, or failed outcome.

### 5.4 Formula

```text
Experimental result deduction = 25 − experimental result score
```

Example successful result:

```text
The expected scientific outcome was successfully produced.
Earned: 25/25. Deduction: -0 points.
```

---

## 6. Scientific Understanding Grading

### 6.1 What is assessed

After the experiment, the student answers **a minimum of 5 and a maximum of 10 automatically graded questions** about the scientific concept, procedure, observation, or result. Every AR experiment must remain within this question-count range. The current built-in experiments each contain 5 questions.

### 6.2 Scoring

The 25 points are distributed proportionally across all questions and rounded to the nearest whole point:

```text
Scientific understanding score =
round((correct answers / total questions) × 25)
```

#### Five-question scoring example

| Correct answers | Calculation | Earned | Deduction | Range |
|---:|---:|---:|---:|---|
| 5 of 5 | `round(5/5 × 25)` | 25 | 0 | Proficient |
| 4 of 5 | `round(4/5 × 25)` | 20 | 5 | Proficient |
| 3 of 5 | `round(3/5 × 25)` | 15 | 10 | Developing |
| 2 of 5 | `round(2/5 × 25)` | 10 | 15 | Developing |
| 1 of 5 | `round(1/5 × 25)` | 5 | 20 | Beginning |
| 0 of 5 | `round(0/5 × 25)` | 0 | 25 | No Evidence |

#### Ten-question scoring example

| Correct answers | Earned | Deduction | Range |
|---:|---:|---:|---|
| 10 of 10 | 25 | 0 | Proficient |
| 9 of 10 | 23 | 2 | Proficient |
| 8 of 10 | 20 | 5 | Proficient |
| 7 of 10 | 18 | 7 | Proficient |
| 6 of 10 | 15 | 10 | Developing |
| 5 of 10 | 13 | 12 | Developing |
| 4 of 10 | 10 | 15 | Developing |
| 3 of 10 | 8 | 17 | Beginning |
| 2 of 10 | 5 | 20 | Beginning |
| 1 of 10 | 3 | 22 | Beginning |
| 0 of 10 | 0 | 25 | No Evidence |

### 6.3 Student feedback

Example:

```text
3 of 5 answers were correct.
Earned: 15/25. Deduction: -10 points.
```

---

## 7. Final Grade Calculation

```text
Final score =
PPE and Safety
+ Procedure, Sequence, and Equipment Handling
+ Experimental Results
+ Scientific Understanding
```

The final score is constrained to **0–100 points**.

### Example final grade

| Category | Earned | Deduction |
|---|---:|---:|
| PPE and Safety | 18/25 | -7 |
| Procedure, Sequence, and Equipment Handling | 15/25 | -10 |
| Experimental Results | 25/25 | 0 |
| Scientific Understanding | 15/25 | -10 |
| **Final score** | **73/100** | **-27** |

---

## 8. Overall Performance Level

The final score receives an overall performance label:

| Final score | Performance level | Interpretation |
|---:|---|---|
| **90–100** | Excellent | Consistently demonstrates safe, accurate, and scientifically sound performance. |
| **80–89** | Proficient | Demonstrates strong performance with only minor mistakes. |
| **70–79** | Developing | Demonstrates basic competency but needs improvement in one or more areas. |
| **0–69** | Needs Support | Requires additional instruction, guided practice, and review. |

The overall label is separate from the category ranges. Category ranges describe performance within each 25-point criterion, while the overall label summarizes the complete 100-point experiment.

---

## 9. Student Result Display

After submitting all 5–10 post-experiment questions, the student sees:

1. the final score out of 100;
2. the overall performance level;
3. all four category scores out of 25;
4. the performance range earned in each category;
5. the exact number of points deducted;
6. the reason for every detected deduction;
7. missing or unnecessary first-attempt PPE;
8. sequence and equipment error counts;
9. experimental result status; and
10. the number of correct scientific-understanding answers.

The student's earned range is highlighted in the rubric table. Scores below 2 do not fall within the Beginning band. The table can be scrolled horizontally on smaller screens.

---

## 10. Stored Rubric Data

Completed AR experiment records store the following rubric information:

| Data key | Meaning |
|---|---|
| `ppe` | PPE and Safety score out of 25 |
| `procedureSequenceEquipment` | Combined procedure, sequence, and equipment score out of 25 |
| `experimentalResult` | Experimental Results score out of 25 |
| `scientificUnderstanding` | Scientific Understanding score out of 25 |
| `correctUnderstandingAnswers` | Number of correctly answered post-experiment questions |
| `totalUnderstandingQuestions` | Total number of post-experiment questions presented |
| `sequenceErrors` | Number of detected sequence errors |
| `equipmentErrors` | Number of detected equipment-handling errors |
| `total` | Final score out of 100 |
| `performanceLevel` | Excellent, Proficient, Developing, or Needs Support |

Previously saved records that used the older 15/35/20/20/10 rubric are converted proportionally when displayed in the teacher's rubric breakdown. New completions use the four-category, 25-points-per-category rubric.

