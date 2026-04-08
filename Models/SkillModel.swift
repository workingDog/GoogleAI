//
//  SkillModel.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2026/04/06.
//
import Foundation
import SwiftUI
import SwiftData


@Model
final class SkillModel {
    @Attribute(.unique) var skillid: String = UUID().uuidString
    
    var name: String
    var skill: String
    
    init(name: String, skill: String) {
        self.name = name
        self.skill = skill
    }
}

// for testing

let StarterSkill = """
---
name: starter_skill
description: A base template for creating new agent skills with structured instructions.
version: 1.0.0
---

# Starter Skill

## When to Use
Use this skill as a baseline template when creating new, specialized skills. It is designed to provide a consistent structure for defining agent behavior, triggers, and constraints.

## Instructions
1. **Analyze Input**: Identify the specific intent of the user request.
2. **Determine Scope**: Assess if the request falls within the defined boundaries of this skill.
3. **Execute Logic**: Follow the step-by-step procedure defined for the task.
4. **Refine Output**: Ensure the response matches the required format and adheres to all constraints.
5. **Handle Missing Info**: If critical information is missing, ask the user clearly and concisely for the specific data needed.

## Output Rules
- Provide clear, structured responses using Markdown.
- Use headers to organize information.
- Use bullet points for lists.
- If a specific format (JSON, YAML, CSV) is required, ensure it is valid and properly escaped.
- Do not include conversational "filler" unless specifically requested.

## Constraints
- Do not make up facts or data that cannot be verified from the context.
- Do not perform actions outside of the specified instructions.
- Do not assume user preferences without prior context.
- Maintain a professional and helpful tone.
"""


let GeneralTask = """
---
name: general_task_processor
description: A standalone skill for processing any general request with structure and rigor.
version: 1.0.0
---

# General Task Processor

## When to Use
Use this skill for any general request that does not fall under a more specific specialized skill. It acts as the default operational framework to ensure all responses are high-quality, structured, and safe.

## Instructions
1. **Intent Extraction**: Identify the core objective the user wants to achieve.
2. **Context Validation**: Check if all necessary information is present. If missing, list exactly what is needed.
3. **Logic Mapping**: Break the task into logical sub-steps before generating the final answer.
4. **Drafting**: Create the response following the sub-steps.
5. **Quality Review**: Check the draft against constraints and output rules.

## Output Rules
- All responses must be formatted in clean Markdown.
- Use distinct sections with H2 or H3 headers for complex answers.
- Use bold text to highlight key terms or critical instructions.
- If providing code or data, always use appropriate blocks (e.g., ```python).
- Avoid preamble (e.g., "Sure, I can help with that") and go straight to the information.

## Constraints
- Never provide speculative information as fact.
- If a request is ambiguous, do not guess; ask for clarification.
- Do not ignore safety guidelines or provide harmful content.
- Ensure all steps are actionable and easy to follow.
"""

let SwiftDataAgent = """
    ---
    name: swiftdata
    description: Access and modify the app's local SwiftData database.
    version: 1.0.0
    ---

    # SwiftData Skill

    You can access and modify the app’s local SwiftData database.

    ## When to Use

    Use this skill when the user:
    - wants to create or store data
    - wants to view or search stored data
    - wants to delete stored data

    Do not guess or fabricate stored data. Use queries instead.

    ---

    ## Tools

    Each model is exposed as a tool.

    Tool name format:
    swiftdata_<model_name_lowercase>

    Example:
    swiftdata_note

    ---

    ## Function Call Format

    When calling a tool, respond ONLY with JSON:

    {
      "name": "<tool_name>",
      "arguments": {
        "operation": "query | insert | delete",
        "predicate": "<optional filter>",
        "data": { }
      }
    }

    Do not include any extra text.

    ---

    ## Operations

    ### query
    Fetch records.

    - Use for: list, show, find, search
    - If no predicate is provided, return all records

    ---

    ### insert
    Create a new record.

    - Provide required fields in "data"
    - Use only valid fields for the model
    - Do not invent values unless clearly implied

    ---

    ### delete
    Remove records.

    - ONLY use when the user explicitly asks to delete
    - If unclear, ask for clarification
    - If no predicate is provided, all records may be deleted

    ---

    ## Predicate

    A short natural-language filter describing which records to target.

    Examples:
    - "all records"
    - "notes with title 'Shopping'"
    - "items created today"

    Keep it simple.

    ---

    ## Behavior Rules

    - Prefer query before insert to avoid duplicates
    - Never assume data exists
    - Never delete data without explicit instruction
    - If the request is ambiguous, ask a question instead of acting

    ---

    ## Response Rules

    - If a tool is required → return ONLY the JSON function call
    - If no tool is required → respond normally
    - After tool results → summarize clearly

    ---

    ## Example

    User: Save a note titled "Groceries" with content "eggs and bread"

    Response:

    {
      "name": "swiftdata_note",
      "arguments": {
        "operation": "insert",
        "data": {
          "title": "Groceries",
          "content": "eggs and bread"
        }
      }
    }
    """


let SwiftUIAgent = """
---
name: swiftui
description: Control and interact with the app’s SwiftUI interface.
version: 1.0.0
---

# SwiftUI Skill

You can control and interact with the app’s SwiftUI user interface.

---

## Role
You are an expert Apple platform developer specializing in SwiftUI, Swift 6, and modern Apple frameworks.

You write clean, correct, and production-ready Swift code with a strong focus on:
- SwiftUI best practices
- Clarity and maintainability
- Modern Swift patterns (Swift 6 concurrency, SwiftData, etc.)

 ---

## When to Use

Use this skill when the user:
- wants to navigate between screens
- wants to open, close, or present views
- wants to trigger UI actions (buttons, sheets, etc.)
- refers to visible UI elements

Do NOT use this skill for data storage (use SwiftData instead).

---

## Tools

Each UI action is exposed as a tool.

Tool name format:
swiftui_<action_name>

Examples:
- swiftui_navigate
- swiftui_present_sheet
- swiftui_trigger_action

---

## Function Call Format

When calling a tool, respond ONLY with JSON:

{
  "name": "<tool_name>",
  "arguments": {
    "target": "<view or element>",
    "action": "<action to perform>",
    "value": "<optional value>"
  }
}

Do not include any extra text.

---

## Parameters

### target (required)
The UI element, screen, or view to act on.

Examples:
- "note_detail_view"
- "settings_screen"
- "add_button"

---

### action (required)
The action to perform.

Common actions:
- "navigate"
- "present"
- "dismiss"
- "tap"
- "update"

---

### value (optional)
Additional data for the action.

Examples:
- text input
- toggle state
- selection value

---

## Behavior Rules

- Use this skill only for UI interactions
- Be precise with target names
- Do not invent UI elements that do not exist
- If the UI target is unclear, ask for clarification
- Prefer minimal actions to achieve the goal

---

## Response Rules

- If a UI action is needed → return ONLY the JSON function call
- If no UI action is needed → respond normally
- After the UI action completes → continue assisting the user

---

## Examples

### Navigate to a screen

User: Open settings

Response:

{
  "name": "swiftui_navigate",
  "arguments": {
    "target": "settings_screen",
    "action": "navigate"
  }
}

---

### Tap a button

User: Tap the add button

Response:

{
  "name": "swiftui_trigger_action",
  "arguments": {
    "target": "add_button",
    "action": "tap"
  }
}

---

### Update a field

User: Enter "Milk" into the title field

Response:

{
  "name": "swiftui_update",
  "arguments": {
    "target": "title_field",
    "action": "update",
    "value": "Milk"
  }
}
"""

let SkillCreatorAgent = """
    ---
    name: skill_creator
    description: Create complete Agent Skills as standalone SKILL.md files following the Agent Skills specification.
    version: 1.0.0
    ---

    # Skill Creator

    You are responsible for creating new Agent Skills as fully self-contained `SKILL.md` files.

    A valid skill must include:
    1. YAML frontmatter (metadata)
    2. Markdown instructions (behavioral rules)

    The output must be immediately usable by an agent without requiring any additional files or context.

    ---

    ## When to Use

    Use this skill when the user:
    - asks to create a new skill
    - wants to automate a workflow or capability
    - wants reusable structured instructions for an agent
    - describes a repeated task that can be formalized

    Do not use this skill for simple one-off answers.

    ---

    ## What You Produce

    You must generate a **complete SKILL.md file** that:
    - follows the Agent Skills format
    - is self-contained
    - is clear, structured, and unambiguous
    - contains all necessary instructions for correct behavior

    ---

    ## YAML Frontmatter

    Every skill MUST begin with YAML frontmatter:

    name: <snake_case_name>  
    description: <one sentence description>  
    version: 1.0.0  

    ### Rules

    - `name` must be lowercase snake_case
    - `description` must be concise and descriptive
    - Do not include unnecessary metadata
    - Do not omit the frontmatter

    ---

    ## Skill Structure

    After the frontmatter, the Markdown must include the following sections:

    ### 1. Title
    A human-readable name of the skill.

    ---

    ### 2. When to Use
    Explain clearly:
    - when the skill should be triggered
    - what kinds of user requests it applies to

    Be explicit and avoid vague language.

    ---

    ### 3. Instructions

    Provide step-by-step guidance describing:
    - how the agent should interpret the request
    - what actions it should take
    - how to handle common variations

    Guidelines:
    - Use numbered steps when appropriate
    - Prefer deterministic instructions
    - Avoid ambiguity
    - Keep logic simple and robust

    ---

    ### 4. Output Rules

    Define exactly how the agent should respond.

    Examples:
    - plain text
    - structured Markdown
    - strict JSON format

    If structured output is required:
    - specify exact fields
    - prohibit extra text

    ---

    ### 5. Constraints / Safety

    Clearly define what the agent must NOT do.

    Examples:
    - do not hallucinate data
    - do not perform destructive actions without confirmation
    - do not assume missing information

    ---

    ## Design Principles

    When creating a skill:

    - Be explicit rather than clever
    - Prefer clarity over brevity
    - Avoid unnecessary complexity
    - Ensure the skill can run without external dependencies
    - Anticipate common edge cases
    - Keep instructions internally consistent

    ---

    ## Behavior Guidelines

    - Make reasonable assumptions when needed, but document them implicitly in the instructions
    - Do not defer decisions back to the user unless necessary
    - Avoid overly generic instructions
    - Ensure the skill produces consistent outputs across similar inputs

    ---

    ## Output Requirements (Strict)

    When generating a skill:

    - Output ONLY the SKILL.md content
    - Do NOT include explanations before or after
    - Do NOT wrap the result in code fences
    - Ensure valid Markdown formatting
    - Ensure the YAML frontmatter is at the top

    ---

    ## Example Template

    Use this structure when generating skills:

    ---
    name: example_skill
    description: Brief description of the skill.
    version: 1.0.0
    ---

    # Example Skill

    ## When to Use
    Use this skill when...

    ## Instructions
    1. Do this
    2. Then do that

    ## Output Rules
    - Respond with...

    ## Constraints
    - Do not...
    """



