# Orbital 2020 - NUSJio
NUSJio is a mobile application that provides NUS students with a platform to widen their social circle by interacting with other students. Through ad hoc meet-ups with students who share similar needs such as ordering delivery or going for a run in NUS, students will be able to find partners to do things together more easily, saving them the disappointment of ending up doing things alone.

## Project Proposal
Link to our project proposal: https://docs.google.com/document/d/1DJ5l0XoyVsnLq2kthwsDtnDrQmAb0Jr9w-VV3m0pjek/edit?usp=sharing

## User Flow Diagram


## UML Diagram


## Video of Mockup
<a href="https://youtu.be/K5IUJBgolqE
" target="_blank"><img src="" 
alt="IMAGE ALT TEXT HERE" width="240" height="180" border="10" /></a>

## GitHub Rules of Engagement
To create a copy of the repository in your own GitHub account, you need to click 'fork' button in GitHub.

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

## Project Log
Link to our project Log: https://docs.google.com/document/d/1uL6GFDatGKhYDMpq8yx2I5anDB_F_b6Rh3VdZXertcQ/edit?usp=sharing