# reader

Unofficial [AO3](https://archiveofourown.org/) reader, aiming to give an iOS-native experience.

## [Quick Demo](https://www.youtube.com/watch?v=fjGoLQPbe7A)

## Current Functionality

- Asyncronous loading of works to not iterrupt the UI
- Basic work information (title, author, tags, stats, etc.) stored on disk for faster experience
    - Works are loaded into memory while reading, but they do not persist between app launches
- Native list for works display, showing relevant work info (rating, words, chapters, kudos, etc.)
- Fully functional search interface with infinite scrolling results
    - Includes tag search to find proper tags
- Clean, native swipe actions to access and manage works
    - Tags/summary view
    - Swipe to delete (if you ever have zero works when opening the app, it will populate with the 3 defaults)
- Progress saving
    - Works remember your last opened chapter
    - Manage unread/in progress/read status
- Swipe open/close sidebar while reading to access chapter list/navigation
- Kudos funcionality
- Basic account login
    - No persistence beyond AO3's own internal session tracking
    - May have to 'reset' login periodically
- Restricted work support
    - Must be logged in
- Import/export by work Id
    - Export ids to clipboard, separated by newlines
    - Import ids from clipboard, saparated by any whitespace
- Adjustable font size

## On The List

- Comments support (this seems the hardest/furthest out for me)
    - May require request throttling and maybe some form of persistence to avoid server strain while retreiving
- More AO3 account features
    - Bookmarks, comments, history, etc.
    - Ideally persist user info for UX, but requires safe credentials management so ??
- Custom themes (the whole app is hardcoded to the default iOS dark theme)
- Alternate font choices
- App Store release? (see [notes](#extra-notes))

## Direct Dependencies

- [SwiftSoup](https://github.com/scinfu/SwiftSoup)
    - For html parsing/manipulation magic
- [SwiftUI-Flow](https://github.com/tevelee/SwiftUI-Flow)
    - For 'flow' style layouts, used in tag display view
    
## Development Notes

If you are compiling/installing yourself, you probably need to set the projects, bundle identifier and development team. I have these settings read
from a `project.xcconfig` file that is not tracked by Git because they have my last name in them.

Changes to the `SwiftData` `@Model`s may require a clean install, there is no schema/migration strategy in place while I'm ironing things out.

I've been developing through the iPhone 16 simulator and personal iPhone 15, both on iOS 18.

## Similar projects/references

- [Unoffical Python AO3 API](https://github.com/wendytg/ao3_api)
    - I've referenced this project a few times, particularly to find out how certain things (like kudos requests) need to be done.
    - Being built in Python, its much easier to use as a reference than find a way to run it on iOS.
- [HTML to markdown in Swift](https://github.com/ActuallyTaylor/SwiftHTMLToMarkdown)
    - My implementation of text parsing is similar to this project, but I have to worry about some edge cases this doesn't cover so I am not using it as a dependency.
    - Because of these edge cases, the parsing isn't perfect, I will likely create something new in the future to handle text parsing better.
    
## Motivations

- I wanted a dark mode on my phone (yes really, thats why I initially started)
- None of my current classes have any coding (I want to stay a little sharp at least)
- I've wanted to learn iOS development for a few years but never had a decent project idea
- I prefer native app experiences better than the web browser

## Extra Notes

### My thoughts on 3rd party apps

Fanfiction has never been my corner of the internet until recently.
Since starting this I've become aware of the ["App Wars"](https://fanlore.org/wiki/AO3_App_Wars) and the community's general feelings towards third party apps.
Obviously re-hosting content is a big no-no, even more so if charging for that content. I understand authors feeling exploited,
even if the in-app purchases of other apps were for seperate features not related to user content. (ads, AI-reader bs, custom themes, etc.)
I agree with this, to a point. Personally I think ads are nothing but a cheap excuse to have IAP and a scummy data collection practice.
I don't think there is a lot of good coming out of anything AI right now either. Even charging for themes feels bad, its just a color swap.
That said, I think the animosity displayed by some memebers of the community was still an overreaction born from a place of misunderstanding and misinformation.

I still think this is a project worth working on, even if for purely personal reasons.
Internet communities can be special places, and I hope this project can show that not *all* third parties are out for a cheap cash grab.

This project will remain open source.

### Potential App Store release

I do hope this becomes finished enough for an App Store release eventually (this would be cool, I've never done that before).
If that is the case, I will not be charging for the app itself or having any IAP of any kind. Also no ads or data collection.
