# Bonfire Feed System Architecture Documentation

  Table of Contents

  1. #overview
  2. #core-components
  3. #data-flow
  4. #feed-types
  5. #preloading-system
  6. #boundary-system
  7. #common-patterns
  8. #troubleshooting-guide

  Overview

  The Bonfire feed system is a sophisticated, modular architecture that handles activity feeds across different contexts
  (notifications, flags, social feeds, etc.). It separates concerns between data queries, boundary checks, preloading, and
  presentation.

  Key Principles

  - Extension-Based Modularity: Different feed types are handled by different extensions
  - Configurable Preloading: Data loading is context-aware and performance-optimized
  - Boundary Enforcement: Comprehensive permission system controls data visibility
  - Dual Query Paths: Activities can be queried directly or through Feed publishes

  Core Components

  1. Feed Infrastructure (bonfire_social/lib/feeds.ex)

  Purpose: Manages feed creation, targeting, and permissions

  Key Functions:
  - feed_preset_if_permitted/2: Checks if user can access specific feed presets
  - feed_ids_to_publish/4: Determines which feeds an activity should be published to
  - moderators/1: Identifies who should receive moderation notifications

  Important Concepts:
  - Feed Presets: Pre-configured feed definitions with specific filters and permissions
  - Feed Publishing: Determines target audiences for activities
  - Permission Context: Different feeds have different access requirements

  2. Feed Loader (bonfire_social/lib/feed_loader.ex)

  Purpose: Central orchestrator for feed queries, filtering, and data loading

  Key Functions:
  - feed/2: Main entry point for feed queries
  - prepare_feed_filters/3: Validates and processes feed filters
  - prepare_filters_and_opts/2: Sets up preloading and boundary options
  - activity_preloads/3: Maps high-level preload keys to specific preloads

  Critical Concepts:
  - Deferred Joins: Performance optimization that applies filters before expensive joins
  - Filter Rules: Context-based rules that determine what data to preload
  - Boundary Integration: Coordinates with permission system

  3. Feed Activities (bonfire_social/lib/feed_activities.ex)

  Purpose: Manages the relationship between activities and feeds through FeedPublish

  Key Schema: FeedPublish
  - feed_id: References any feed (user inbox, notifications, etc.)
  - activity_id: References the activity being published
  - Acts as join table between feeds and activities

  4. Activities (bonfire_social/lib/activities.ex)

  Purpose: Core activity management and preloading

  Key Functions:
  - activity_preloads/3: Applies context-specific data preloading
  - as_permitted_for/3: Applies boundary checks to activities
  - prepare_subject_and_creator/2: Ensures user data is properly loaded

  Critical Schema: Activity
  - subject_id: Who performed the action
  - verb_id: What type of action (create, like, flag, etc.)
  - object_id: What was acted upon

  5. Edges (bonfire_social/lib/edges.ex)

  Purpose: Handles direct relationships between entities (likes, follows, flags)

  Key Schema: Edge
  - subject_id: Who performed the action
  - object_id: What was acted upon
  - table_id: What type of relationship
  - Important: Creates both Edge record AND Activity record

  Data Flow

  Activity Creation Flow

  1. User Action (e.g., flag, like, post)
     ↓
  2. Edge.insert() OR Activities.create()
     ↓
  3. Creates Activity record
     ↓
  4. Determines target feeds (feed_ids_to_publish)
     ↓
  5. Creates FeedPublish records
     ↓
  6. Publishes to feeds (notifications, outbox, etc.)

  Feed Query Flow

  1. Feed Request (e.g., :notifications, :flags)
     ↓
  2. Feed Preset Lookup (permissions check)
     ↓
  3. Filter Preparation (context-specific rules)
     ↓
  4. Query Construction (Activities vs Edges)
     ↓
  5. Preload Application (based on context)
     ↓
  6. Boundary Filtering (permission enforcement)
     ↓
  7. Data Presentation

  Feed Types

  1. Social Feeds (Activity-based)

  - Data Source: Activity joined with FeedPublish
  - Query Path: FeedActivities.base_query() → Activities.activity_preloads()
  - Examples: :my, :local, :notifications
  - Characteristics: Complex preloading, boundary-aware

  2. Edge Feeds (Edge-based)

  - Data Source: Edge table directly
  - Query Path: Edges.query_parent() → direct edge preloads
  - Examples: :flags, :likes, :follows
  - Characteristics: Simpler queries, direct object relationships

  3. Special Feeds

  - Custom Queries: Some feeds bypass standard patterns
  - Examples: :curated (uses Pins.list_instance_pins)
  - Characteristics: Domain-specific optimizations

  Preloading System

  Context-Based Preloading Rules

  The system uses rules defined in runtime_config.ex to determine what data to preload based on feed context:

  # Example from runtime_config.ex
  "Notifications Feed (Only for me)" => %{
    match: %{feed_name: :notifications},
    include: [:with_seen, :with_reply_to, :emoji, :with_flagged_user]
  }

  Preload Types

  - :with_creator: Loads object creator (for posts, media)
  - :with_subject: Loads activity subject (who performed action)
  - :with_object_more: Loads object with profile/character data
  - :with_reply_to: Loads replied-to content with boundaries
  - :with_seen: Adds seen/unseen status for current user

  Performance Optimizations

  1. Deferred Joins: Apply filters before expensive preloads
  2. User ID Skipping: Avoid loading current user data redundantly
  3. Context Rules: Only load what's needed for specific contexts
  4. Pointer Resolution: Special handling for Needle pointers

  Boundary System

  Permission Layers

  1. Feed Access: Can user access this feed type?
  2. Activity Visibility: Can user see this activity?
  3. Object Visibility: Can user see the activity's object?

  Key Concepts

  - skip_boundary_check: Bypasses permission checks (for moderators)
  - include_flags: Controls flag visibility (:mediate, :admins, true, false)
  - Verb Permissions: Different actions require different permissions

  Permission Patterns

  # Admin/Moderator Pattern
  skip_boundary_check = case include_flags do
    :admins -> is_admin?(user)
    :mediate -> can?(user, :mediate, :instance)
    true -> true
    _ -> false
  end


  Troubleshooting Guide

  Issue: Missing Data in Feeds

  Symptoms: Objects show in one feed but not another
  Check:
  1. Feed Type: Activity-based vs Edge-based queries
  2. Preload Rules: Different contexts have different preloads
  3. Boundary Checks: Permission differences between feeds
  4. Pointer Resolution: User objects need special handling

  Common Causes:
  - Missing preload in feed configuration
  - Boundary checks filtering out data
  - Incorrect pointer resolution for User objects

  Issue: Performance Problems

  Symptoms: Slow feed loading
  Check:
  1. Deferred Joins: Enabled for large datasets?
  2. N+1 Queries: Proper use of proload vs preload
  3. Context Rules: Loading too much unnecessary data?

  Issue: Permission Errors

  Symptoms: Unauthorized access or missing content
  Check:
  1. Feed Presets: Correct permission requirements?
  2. include_flags: Proper moderator permissions?
  3. Boundary Configuration: Object-level permissions set correctly?

  Debugging Steps

  1. Check Feed Preset: Is the feed accessible to the user?
  2. Verify Filters: Are the correct filters being applied?
  3. Examine Preloads: Is the necessary data being loaded?
  4. Test Boundaries: Are permission checks working correctly?
  5. Compare Query Paths: Activity vs Edge queries for same data

  Implementation Checklist

  When working on feed-related features:

  Before Starting

  - Identify feed type (Activity vs Edge based)
  - Check existing preload rules for context
  - Understand permission requirements
  - Review similar implementations

  During Implementation

  - Add appropriate preload rules to runtime_config.ex
  - Handle User objects with pointer_query if needed
  - Respect boundary check patterns
  - Consider performance implications
  - Test with different user permission levels

  Testing

  - Test as regular user
  - Test as moderator/admin
  - Verify preloading works correctly
  - Check performance with large datasets
  - Ensure boundary checks work as expected

  This documentation should serve as a comprehensive reference for understanding and working with the Bonfire feed system, eliminating
  the need for extensive research on each feed-related task.