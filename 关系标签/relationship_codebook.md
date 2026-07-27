# Firm–developer relationship codebook

## Scope

The coding unit is a listed security–model developer pair. The current grid
contains 45 NDXT securities and 25 developers, producing 1,125 pairs.
GOOGL and GOOG are separate securities. Each pair receives eight binary
indicators, confidence codes for positive labels, and a short justification.

The 25 developers are OpenAI, Google, Anthropic, DeepSeek, Alibaba, xAI, Meta,
Mistral, Microsoft, Kimi, Z AI, Amazon, MiniMax, Stability.ai, Midjourney,
Runway, Black Forest Labs, Suno, Udio, Kyutai, Recraft, KlingAI, Vidu,
ElevenLabs, and ByteDance Seed.

## General rules

1. Labels are multi-dimensional. A pair may receive several positive labels.
2. R3, R4, and R5 are mutually exclusive.
3. R1–R5 describe the listed firm's operating position. They may repeat across
   developers when the position is structural.
4. R6, F1, and F2 are developer-specific.
5. R6 requires overlap in model modality. Language, image, video, audio, and
   multimodal competition are evaluated separately.
6. A positive label must have public support. Ambiguous cases default to zero.
7. Confidence is H, M, or L for positive labels and blank for zero labels.

## Position definitions

### R1 `upstream_hardware`

The firm supplies physical inputs used in model training or inference. This
includes accelerators, CPUs, memory, storage, semiconductor equipment,
advanced packaging, networking, and power-management components used in AI
data centers.

General-purpose electronics with no material AI-compute connection do not
qualify.

### R2 `upstream_cloud`

The firm operates hyperscale computing infrastructure that rents training or
inference capacity and hosts third-party foundation models.

Ordinary SaaS use, colocation real estate, and internal data centers do not
qualify.

### R3 `downstream_integrator`

The firm embeds third-party foundation models into a product or platform sold
under its own brand. Model capability is a material product input.

### R4 `downstream_deployer`

The firm uses generative AI in a broader operating business whose primary
product lies outside foundation models and AI infrastructure.

### R5 `downstream_enabler`

The firm advises, implements, integrates, or operates AI systems for enterprise
clients as a service.

### R6 `competitor`

The firm or its listed parent develops foundation models in the same modality
as the releasing developer. Fine-tuning, ordinary application development,
and narrow predictive models do not qualify.

For a developer's own listed security, F2 records ownership. R6 may still
record the firm's position relative to other developers but is not used to
replace F2.

### F1 `is_investor`

The listed firm holds a direct equity stake in the model developer. Commercial
contracts without an equity stake do not qualify.

### F2 `is_owner`

The listed firm is the model developer or its listed parent or publisher.

## Coding and adjudication

Coders A and B applied this codebook independently to the complete 45×25 grid.
Disagreements were adjudicated at the individual binary-cell level. The
original codings are in `关系标签/coding_evidence/`, and the final table is
`事件集筛选/decisions/relationship_decisions.csv`.
