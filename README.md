# Arc

Arc is a short-form movie and TV reflection app built with SwiftUI. Users can discover movies and TV shows, create personal reflections, rate content, select genres of interest, and interact with other users through likes, comments, replies, and reposts.

## Features

- Search for movies and TV shows using TMDB
- Create short-form reflections (Arcs)
- Rate content from 0–10
- Select up to 3 themes
- Mark reflections as spoilers
- Like and repost Arcs
- Comment and reply to Arcs
- Edit and delete your own Arcs
- Edit and delete your own comments/replies
- Genre-based content recommendations
- Movie and TV browsing
- Local JSON data persistence for development
- Unit and UI testing

## Architecture

Arc follows an MVVM architecture with an additional Use Case layer:

- SwiftUI Views
- ViewModels
- Use Cases
- Models
- DummyDataStore / TMDB API

Important Use Cases include:

- `CreateArcUseCase`
- `ArcEditUseCase`
- `ArcDeleteUseCase`
- `ArcLikesUseCase`
- `ArcRepostUseCase`
- `SubmitCommentUseCase`
- `SubmitReplyUseCase`
- `SearchContentUseCase`

Business rules such as reflection length, rating limits, ownership, and comment validation are handled by the Use Case layer rather than directly in the Views.

## Requirements

- Xcode 16 or later
- iOS 26 or later (Simulator or compatible Apple device)
- Swift 5.10+
- A TMDB account

## TMDB API Setup

Arc requires a TMDB API Read Access Token to search for and retrieve movie and TV information.

1. **Create a TMDB account**
   Sign up at [The Movie Database (TMDB)](https://www.themoviedb.org/).

2. **Create an API application**
   Go to your TMDB account settings and create an API application. TMDB provides two commonly encountered credentials:
   - API Key (v3 auth)
   - API Read Access Token

   Arc requires the **API Read Access Token**. The project uses it as a Bearer token:

```swift
   request.setValue(
       "Bearer \(tmdbAccessToken)",
       forHTTPHeaderField: "Authorization"
   )
```

3. **Add your token to the project**
   Create an `APIKeys.swift` file in the Arc project if one doesn't already exist:

```swift
   import Foundation

   enum APIKeys {
       static let tmdbAccessToken = "YOUR_TMDB_API_READ_ACCESS_TOKEN"
   }
```

   Replace `YOUR_TMDB_API_READ_ACCESS_TOKEN` with your TMDB API Read Access Token.

   > **Note:** Do not use the TMDB v3 API Key here — this field requires the Read Access Token specifically.

4. **Keep your API credential private**
   Do not commit your real TMDB token to a public GitHub repository. If using Git, add the credentials file to `.gitignore`:
If the token has already been committed or publicly exposed, revoke/rotate it through TMDB and replace it with a new one.

## Running the Project

1. Clone or download the Arc project.
2. Open the `.xcodeproj` or `.xcworkspace` in Xcode.
3. Add your TMDB API Read Access Token to `APIKeys.swift`.
4. Select an iOS/iPadOS Simulator or connected device.
5. Build and run the project.

The app uses local JSON persistence through `DummyDataStore`, so a separate database or CloudKit configuration is not required for the current version.

## Testing

Arc contains separate tests for application logic, API functionality, and UI flows.

### Unit Testing

The unit tests cover core business operations, including:

- Creating valid Arcs
- Rejecting invalid reflection lengths
- Rejecting invalid ratings
- Editing Arcs
- Liking and unliking Arcs
- Reposting and unreposting Arcs
- Creating comments and replies
- Deleting Arcs and their associated comments/replies
- Rejecting empty comments
- Rejecting replies to deleted comments

### API Testing

The API tests verify that Arc can:

- Retrieve movie details from TMDB
- Search for movies through TMDB
- Reject invalid search input

### UI Testing

The UI tests verify important user flows, including searching for content and opening a movie result.

## Data Storage

CloudKit/backend infrastructure is outside the scope of the current assignment implementation. Arc currently uses `DummyDataStore` with local JSON persistence for development and demonstration purposes.

The application stores data in:

`dummyDataV2.json`


This includes local users, Arcs, comments, and replies.

## Content Data

Movie and TV metadata is provided by [TMDB](https://www.themoviedb.org/). Arc uses TMDB to retrieve information such as:

- Titles
- Posters
- Descriptions
- Genres
- Credits
- Recommendations

Search and recommendation requests use TMDB's adult-content filtering where supported.

## Assignment Scope

Arc was developed as a university solution engineering project. The current implementation focuses on demonstrating:

- MVVM architecture
- Use Case driven business logic
- Domain-specific validation
- Human-system interaction
- API integration
- Local persistence
- Automated testing

A production version could replace the local JSON storage with a proper backend or CloudKit, and introduce more advanced, personalised recommendation functionality.


