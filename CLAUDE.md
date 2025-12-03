# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Study Buddy is a Rails 7.1 application for managing study materials. Users can organize lectures into categories, create flashcards for studying, take notes, and interact with an AI assistant (via ruby_llm gem) for each lecture.

## Development Commands

```bash
# Start the server
bin/rails server

# Database operations
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed

# Run all tests
bin/rails test

# Run a single test file
bin/rails test test/models/user_test.rb

# Run a specific test by line number
bin/rails test test/models/user_test.rb:10

# Rails console
bin/rails console

# Asset pipeline
bin/rails assets:precompile
```

## Tech Stack

- Ruby 3.3.5 / Rails 7.1.6
- PostgreSQL database
- Hotwire (Turbo + Stimulus) for frontend interactivity
- Bootstrap 5.3 for styling
- Devise for authentication
- Active Storage with AWS S3 for file uploads
- ruby_llm gem for AI integration

## Architecture

### Data Model

```
User
├── has_many :categories
├── has_many :flashcards (through :flashcard_completions)
└── lectures (derived from categories)

Category
├── belongs_to :user
└── has_many :lectures

Lecture
├── belongs_to :category
├── has_one_attached :document (Active Storage)
├── has_many :flashcards
├── has_many :notes
└── has_many :messages (AI chat history)

Flashcard
├── belongs_to :lecture
├── content (question)
├── expected_answer
└── has_many :users (through :flashcard_completions)

FlashcardCompletion (join table with status tracking)
├── belongs_to :user
├── belongs_to :flashcard
└── status

Message (AI chat)
├── belongs_to :lecture
├── role (user/assistant)
└── content
```

### Route Structure

- Root: `pages#home`
- Categories are nested under users (implicitly via `current_user`)
- Lectures nested under categories for creation, standalone for viewing/editing
- Flashcards, notes, and messages are nested under lectures

## Environment Variables

The app uses dotenv-rails for environment configuration. Required variables should be set in `.env` file (not committed to git).
