# CARFAX Listing App
## Take Home Project for Interview Purposes

## Technology Overview
### Diffable Data Source
### MapKit
### Contacts
### Search Controller
### JSONDecoder and Results Type
### Context Menu

## Challenges:
### Images
- While each image had the same height and width, the actual content of the image did not properly fill the frame. As such, I noticed some white bars on top and bottom of the images when downloaded from the API, which caused unpleasant viewing experience.
### API 
- API was very complex and complicated, with deeply nested branches within branches.
    - This complexity made data persistence an issue (using Core Data).
    - Firebase would have worked better, but given the nature of the assignment, I opted not to use third party libraries.
- Since the API is static, I was not able to make a GET request with specific parameters.
    - As such, I had to be creative with data persistence, which required me to make a network call to fetch the listings and filter the listing by the `id` property that is assigned to each listing.


## Disclaimer:
App Icon image was obtained by CARFAX Car Care App Icon asset, downloaded from [App Store Marketing Tools](https://tools.applemediaservices.com/app/552472249?country=us). CARFAX Logo was obtained from the [CARFAX Website](https://www.carfax.ca). All image assets belong to CARFAX.
