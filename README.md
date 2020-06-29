# Orbital 2020 Artemis Project - NUSJio
NUSJio is a mobile application that provides NUS students with a platform to widen their social circle by interacting with other students. Through ad hoc meet-ups with students who share similar needs such as ordering delivery or going for a run in NUS, students will be able to find partners to do things together more easily, saving them the disappointment of ending up doing things alone.

## Project Proposal
Link to our project proposal: https://docs.google.com/document/d/1DJ5l0XoyVsnLq2kthwsDtnDrQmAb0Jr9w-VV3m0pjek/edit?usp=sharing

## Core Features （this section has been edited recently)
1. Activity:
   
   This is the most important element of our application. Users can create their own Jio (activity), while specifying the intended location (location can be anywhere within Singapore) and time. Users can also post limits on who can participate. There are two kinds of activites, private and public. Private activities can only be joined after joining requests are approved by the host. We expect this to be the more common type of activity used by users. For public activities, any user can join as long as the specific activity is still valid (i.e. has not ended). Details of activities include number of participants, faculties of participant (can be more than one), participants gender (M, F or mixed), description given by the host etc. All current participants will also be displayed for users to decide whether they want to join.

2. Login Page:

   Users must use their NUS account to sign in. This is to ensure this application is for NUS staff and students only. It also makes it easier to contact users should any accidents or unfortunte events happen.

3. Activity Page:

   This is the first page that users see once they logged in. This page displays any future activities that users have, and highlights any activities that is happening today. This makes sure that user would not miss any of the activities. Under every activities, there are two buttons, one to start the activity immediately, another one to postpone the activity. After the activites are ended by the host, both participants and hosts will be prompted to write reviews for other participants.

4. Explore Page:

   This page is for users to have a quick look at activities scheduled by other users. Users can either search for specific activites or simply scan through various activites. Activites occuring sooner and nearer to the user will have higher priority in the queue. Users can also filter their search by activity type, number of participants and etc.

5. Create Your Activity

   If the users cannot find ideal Jio from explore page, they can always create their own Jio using Create feature. In order to create a Jio, users need to craft a title, add a brief description and any other specifications and restraints on who can join (such as gender limit, participant number limit, faculty limits etc). They also need to select a location and schedule a time for the Jio.

6. Message Page

   Users can chat with the host of an activity before they join. After joining, users will enter the group chat containing the host and all other participants.

7. My Account Page

   This page contains user's account information. User's view history, activity history, likes, and all activities started by themselves can be found in this page. It can also lead to setting page where users can set their basic preferrence.

8. Other features

   Report: users can file reports on other participants for any misconduct. All reports will be dealt with seriousy. If found legit, the cases will be transferred to NUS for further investigation.

## Our Current Progress
The app employs a classic structure with five navigation controllers embedded in a tab bar controller. After the user signs up/ logs in, the tab bar controller becomes the root view controller of the app. The followings are our current progress:
1. Log in and sign up view controllers are complete. When user sign up, the app will check whether the email is valid nus email (friendly or default) and give out corresponding error messages. When user transits from log in or sign up view to my activities view, a loading overlay is added to smooth out the transition.
2. "My Activities" page is the first tab of the tab bar controller. It displays the currently signed in user's activities, including both activities that he/she created and joined. The activities are ordered by time with the most recent at the top. User can click any activity to view the activity detail. Host of the activity is able to edit it. The transition from "Activity Detail" to "Add/Edit Activity" is done by programmatically walking up and down the navigation hierarchy to root view tab bar controller to switch tab.
3. "Activity Detail" page allows the user to view the detail
4. Yuqing TODO: Search page
5. "Add/Edit Activity" page is the third tab of the tab bar controller. It allows user to create an activity by specifying the name, location, time and upload an image as the cover picture. A progress view is used to show the progress is image uploading. A map view and search function is also implement so that users can find their desired place easier. It is present modally by overriding the tab bar delegate method shouldSelect. Users can arrive at this page either by the "Edit" button in "Activity Detail" page or by pressing the middle button of the tab bar. Transition from "Activity Detail" to "Add/Edit Activity" is similarly achieved by programmatically walking up and down the navigation hierarchy. When user save the activity, the tab switching from this page to "Activity Detail" page is done by the same trick. Customised delegate is used to pass down the saved activity to the destination view controller. 
6. "Me" page currently displays user information such as username, email, uuid and password. User can sign out here. 
7. User and activity data are stored in two separate collection in cloud firestore. Images are stored in firestorage. Functions that communicate with firebase are all abstracted away in a single swift file DataController.swift in compliance to the Open Close principle, making it easier to build on the project in the future. As most backend events happen asynchronously, transaction is used to ensure no one join the to-be-deleted activity when delete is happening.
8. Security rules in the server side allows everyone to write into the collection("users") to create user but only authenticated user can read data from collection("users"). For collection("activities"), only authenticated users are allowed to read and update activity. Furthermore, the title of the activity cannot be null for the create and updated to proceed, which is in accordance to the client code in "Add/Edit Activity" page. Only host of an activity is allowed to delete it.
9. Splash screen and app logo are designed by ourselves. 

## Features to be Completed in Milestone 3
1. Divide my activities page to two section. One for activities of today and one for the future activities.
2. Complete participants and filter part for activity detail
3. Message functionality
4. User will be able to join and postpone the activity
5. Implement real time listener/ refresh functionality to update participants for every activity.
6. Remove expired activities 

## Testing
User testing is done as shown in the updated project video.
(Yuqing TODO: Add the youtube link here)

## User Flow Diagram
![user_flow_diagram_simple](https://github.com/zeling595/Orbital2020-NUSJio/blob/master/Media/user_flow_diagram_simple.jpg)

## UML Diagram
![UML_diagram](https://github.com/zeling595/Orbital2020-NUSJio/blob/master/Media/UML_diagram.pdf)

## Video of Prototype
<a href="https://youtu.be/K5IUJBgolqE
" target="_blank"><img src="https://github.com/zeling595/Orbital2020-NUSJio/blob/master/Media/mockup_video_thumbnail.jpg" 
alt="IMAGE ALT TEXT HERE" width="240" height="520" border="10" /></a>

## GitHub Rules of Engagement
To create a copy of the repository in your own GitHub account, you need to click 'fork' button in GitHub

Clone the project to your local machine



`$ git clone https://github.com/zeling595/Orbital2020-NUSJio.git`

Change into new project directory


`$ cd .../NUSJio_app`


Set up a new remote that points to the original project so that you can grab any changes and bring them into your local copy
1. origin points to your GitHub fork of the project. You can read and write to the project
2. remote_name points to the main GitHub repository. You can only read from this project


`$ git remote add remote_name https://github.com/zeling595/Orbital2020-NUSJio.git`

After you have done your changes, branch out from master branch for fixing bug or development branch for adding new features

1. For working with master branch



`$ git checkout master`



`$ git pull remote_name master && git push origin master`

2. For working with development branch



`$ git checkout development`



`$ git pull remote_name development && git push origin development`

Make your own branch and move to it



`$ git branch -b branch_name`



Commit and push changes


`$ git add filename>`


`$ git commit -m "Commit message"`


Create pull request. Push your branch to the origin remote and then press some buttons on GitHub



`$ git push -u origin branch_name`


This will create the branch on your GitHub project. The -u flag links this branch with the remote one, so that in the future, you can run 



`$ git push origin`

Go to your fork of the project and your new branch is listed at the top. Click “Compare & pull request” button. Fill in the form and click "Create pull request". Code maintainers will review your code.
