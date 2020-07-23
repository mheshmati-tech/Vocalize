# Vocalize
## An ios app to capture your thoughts and feeling using your voice; to *Vocalize* your experiences. 
###### This app was built as my capstone project, reflecting the tremendous skills and knowledge gained through Ada's 6 months-long classroom curriculum. [Ada Developers Academy](https://adadevelopersacademy.org/) is a non-profit coding bootcamp for women and gender-diverse individuals, located in Seattle WA.
###### Built by [Maryam (Mair) Heshmati](https://www.linkedin.com/in/maryam-mair-heshmati-297a7710b/)
###### [Ada Developers Academy Capstone Project](https://github.com/mheshmati-tech/Vocalize)  




## Table of Contents 
* [Capstone Concept/Introduction](#introduction)
* [Learning Goals](#learning-goals)
* [App Features](#app-features)
* [Technologies](#technology-stack)
* [Installation](#install-vocalize)
* [Further Enhancements](#enhancements)

## Introduction
Do you ever start talking about something that's been on your mind and suddenly have a realization, or feel lighter because you were prompted to organize your thoughts better? Do you ever wonder, if there's a pattern with the day of the week and your mood? Do you ever have a great idea but don't have a pen and paper to write it down or better yet, do you ever feel like the speed of which your thoughts are generated does not match the speed of your writing? 

I introduce to you *Vocalize*, an IOS app meant to help users to journal and capture their thoughts, feelings, ideas, and mood on the go. 

I wanted to build an app that gives users the necessary tools to simplify and ease reflection, a fundamental part of growth. "Reflection gives the brain an opportunity to pause amidst the chaos, untangle and sort through observations and experiences, consider multiple possible interpretations, and create meaning." With 90% of cell phone owners reporting they "frequently" carry their phone with them, this app makes journaling more accessible. The audio to transcription feature enables an effortless experience for a journal entry. Moreover, since the data is saved on the user's device and is not backed up to any cloud server, it makes the app more secure and ensures privacy of the user's intimate entries. 





## Learning Goals
- The fundamentals of building an IOS app using XCode. 
- The fundamentals of voice recording and saving the files to a database. 
- Incorporate machine learning model to predict sentiment from text. 


## Features
<p align="center"> 
     <img src="https://gfycat.com/ifr/ShowyUnrulyLiger.gif"
          alt="By Location Demo"
          width="640"/>
</p>



## Technology Stack
- Back-end: SQLite via CoreData Framework
- Front-end: Swift 5 (using XCode 11)
- APIS: Microsoft Azure Text Analysis API

## Install Vocalize
1. Download this repo
2. Open in Xcode 11
3. Install and add [StatusAlert](https://github.com/LowKostKustomz/StatusAlert) to dependencies. 
4. Follow [these directions](https://docs.microsoft.com/en-us/powerapps/maker/canvas-apps/cognitive-services-api) to sign up for text analytics with Azure and get Client secret for API calls. Make a seperate file that has "APIKey" struct defined and use "ClientSecret" variable to hold Client Secret. Make sure to add this file to .gitignore before commiting it to Github. 

Build and run this project on an iPhone 11 or simulator with ios 13+. 

## Further Enhancement 
Due to constraint in timing, these are future enhancements I'd like to make.
1. Have a graph on a page to visualize the user's data (mood/sentiment) over time. 
2. Incorporate more logic that takes into consideration the confidence score given back with every sentiment analysis API call to ensure accuracy.
3. Add a tag-feature where each recording can be tagged and grouped/searched via their associated tag. 
4. Customize mental health tools/resources for each user depending on their entries and sentiment analysis. 


