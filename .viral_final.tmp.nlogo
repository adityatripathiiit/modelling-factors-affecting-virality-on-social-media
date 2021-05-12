extensions [ nw ]
;; The global parameters
globals [
  sharing-rates            ;; sharing rates is a list storing the sharing rates of the 16 types of videos
  total-times-shared       ;; number keeping track of the total number of time a content is shared
  video-sharing-likelihood ;; set to [42.3 38.8 31.7 29.5 28.8 28.4 28.1 26.7 23.8 20.0 19.7 15.6 15.3 14.0 12.8 9.8] depending on the Broxton paper, for the 16 video
  social-motivation-types  ;; set to [“opinion-seeking” “shared-passion” “social-utility” “kudos” “zeitgeist” “social-good” “reaction-seeking” “self-expression” “emotional-experience”] depending on research of Phil Nottingham.
]
;; user parameters
turtles-own [
  videos-viewed          ;; A dynamic list variable, containing id’s of the content/video viewed by the user
  my-sharing-likelihood  ;; A static variable which represents the sharing likelihood of a user, for the content/videos
  number-of-times-shared ;; A dynamic variable, representing the number of times any content/video has been shared by this user
  is_recommending?       ;; A dynamic variable, representing if the user is open to share any content or not
  previous-recommender   ;; A dynamic variable, representing the user(turtle) who immediately recommended some content to a other user.
]
;; connection parameters
links-own[ connection-strength ] ;; variable representing connection strength between two links
;; environment parameters
patches-own [
  video-type              ;; A static variable, representing the type of the video/content
  video-id                ;; A static varaible, contaning the id of the video/content. Each video has a unique id assigned to it.
  number-of-times-viewed  ;; A static variable, representing the number of times the content on this patch is viewed by the user.
  social-motivation-index ;; A static list where each value of the list ranges from 1 to 5 and represents the social-emotion-index of a content/video
]
;; setup procedure
to setup
  clear-all      ;; clearing plots and simulation window
  create-network ;; setting up the network and social graph
  set-parameters ;; setting up the global parameters
  create-content ;; setting up the environment and creating video on each patch
  reset-ticks    ;; resetting the ticks after set up
end
;; procedure for setting up global variables
to set-parameters
   set total-times-shared 1
   set sharing-rates [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]    ;; sharing rate for each video type is initialized to zero
   set video-sharing-likelihood [42.3 38.8 31.7 29.5 28.8 28.4 28.1 26.7 23.8 20.0 19.7 15.6 15.3 14.0 12.8 9.8] ;; likelyhood for 16 video types as given in Broxton paper
   set social-motivation-types ["zeitgeist" "opinion-seeking" "experience" "perseverence" "kudos" "social-welfare" "reaction" "expression" "utility"] ;; types of social motivation
end
;; Procedure to create videos or setup the environment
to create-content
  (foreach (sort patches ) (n-values count patches [t -> t])[ [x y] -> ask x [set video-id y] ]) ;; assigning each video a unique video id reference "https://stackoverflow.com/questions/30055169/netlogo-how-to-give-each-patch-an-unique-identity-plabel-name"
  ask patches [ create-one-video] ;; ask each patch to create video and set the videos social motivation index, and set the type of the video
  divide-world ;; divide the world into 16 parts according to video types, color them and show the video type in the background of the model interface.
end
;; procedure to create a new video at a patch
to create-one-video
  set social-motivation-index ( list  (random 5 + 1) (random 5 + 1) (random 5 + 1) (random 5 + 1) (random 5 + 1) (random 5 + 1) (random 5 + 1) (random 5 + 1) (random 5 + 1) ) ;; randomly assign social motivation values for each type
  set number-of-times-viewed 0 ;; set the number of views of this video to be zero
  set-video-type               ;; set the video type depending on the location of the patch
end
;; procedure to set the video type depending on the location of the patch it is called from
to set-video-type
  ;; dividing into 16 parts and assigning each part a type, which can even be seen in the background of the model interface
  if pxcor <= -8 and pxcor >= -16 and pycor <= 16 and pycor >= 8 [ set video-type 1 ]
  if pxcor <= -8 and pxcor >= -16 and pycor <= 8 and pycor >= 0 [ set video-type 2 ]
  if pxcor <= 0 and pxcor >= -8 and pycor <= 16 and pycor >= 8 [ set video-type 3 ]
  if pxcor <= -8 and pxcor >= -16 and pycor <= 0 and pycor >= -8 [ set video-type 5 ]
  if pxcor <= 0 and pxcor >= -8 and pycor <= 8 and pycor >= 0 [ set video-type 4 ]
  if pxcor <= 8 and pxcor >= 0 and pycor <= 16 and pycor >= 8 [ set video-type 6 ]
  if pxcor <= -8 and pxcor >= -16 and pycor <= -8 and pycor >= -16 [ set video-type 7 ]
  if pxcor <= 0 and pxcor >= -8 and pycor <= 0 and pycor >= -8 [ set video-type 8 ]
  if pxcor <= 8 and pxcor >= 0 and pycor <= 8 and pycor >= 0 [ set video-type 9 ]
  if pxcor <= 16 and pxcor >= 8 and pycor <= 16 and pycor >= 8 [ set video-type 10 ]
  if pxcor <= 0 and pxcor >= -8 and pycor <= -8 and pycor >= -16 [ set video-type 11 ]
  if pxcor <= 8 and pxcor >= 0 and pycor <= 0 and pycor >= -8 [ set video-type 12 ]
  if pxcor <= 16 and pxcor >= 8 and pycor <= 8 and pycor >= 0 [ set video-type 13 ]
  if pxcor <= 8 and pxcor >= 0 and pycor <= -8 and pycor >= -16 [ set video-type 14 ]
  if pxcor <= 16 and pxcor >= 8 and pycor <= 0 and pycor >= -8 [ set video-type 15 ]
  if pxcor <= 16 and pxcor >= 8 and pycor <= -8 and pycor >= -16 [ set video-type 16 ]
end
;; function to divide the world visually on model interface
to divide-world
  ask patches [ ;; ask all the patches to set their label to their video type  and their color accordingly
    set pcolor black
    set plabel-color 6 + video-type * 10
    set plabel video-type
  ]
end
;; procedure to setup the network
to create-network
  if social-graph-type = "random" [  nw:generate-random turtles links number-of-users 0.1 ]                                    ;; random network with 10 % chance of being connected
  if social-graph-type = "preferential" [ nw:generate-preferential-attachment turtles links number-of-users 1 ]                ;; preferential network
  if social-graph-type = "smallworld" [ let sq sqrt number-of-users nw:generate-small-world turtles links sq sq 2.0 false ]    ;; small world network
  setup-links                                                                                                                  ;; setup the connection links and initialize their strength to 1
  ask turtles [                                                                                                                ;; create users/ turtles
    set shape "person"
    set color cyan + 3
    setxy random-xcor random-ycor               ;; randomly position the turtle on the map, this represents default recommendations by social platform (say youtube)
    set videos-viewed []
    set my-sharing-likelihood random 100 / 100  ;; setting sharing likelihood to be random float between 0 and 1
    set previous-recommender nobody             ;; setting previous-recommender to nobody as no one has shared any content to any one
    set is_recommending? false                  ;; since this user is currently not sharing, set is_recommending to false
  ]
end
;; procedure to setup the network links
to setup-links
  ask links [
    set connection-strength 1     ;; default connection strength is 1
    set label connection-strength
  ]
end
;; the go procedure
to go
                                                                ;; asks turtles to view a video and then try to watch a new video at each time step
  ask turtles  [
    view                                                        ;; ask turtles to view
    see-new-video                                               ;; ask turtles to watch new vdeo
  ]
  if( ticks != 0 and ticks mod video-removal-rate = 0 ) [       ;; decide to remove videos every video-removal-rate time steps
    decide-to-remove
  ]
  if( ticks > 3100) [stop]                                      ;; run for 31 days
  tick
end
;; procedure to remove videos
to decide-to-remove
  let to-delete []                                      ;; list to store the ids of the removed video
  ask patches [                                         ;; for all the videos
    if random-float 1 < video-removal-probability [     ;; with a probability video-removal-probability, remove the video
      set to-delete lput video-id to-delete             ;; if the video is removed, set the id of the video in the to-delete list for later processing
      create-one-video                                  ;; create a new video in place of the previous video
    ]
  ]
  foreach to-delete [                                   ;; for each deleted video
      t ->
      ask turtles [                                     ;; ask all the users
        if member? t videos-viewed [                    ;; if this video-id is present in their viewed list
          set videos-viewed remove t videos-viewed      ;; if so remove it from their viewed list
        ]
      ]
    ]
end
;; procedure to watch a new video
to see-new-video
  let people-recommending my-links with  [[ is_recommending?] of other-end]                        ;; Finding all the connection of current user, who are willing to share video/content
  if( any? people-recommending) [                                                                  ;; if any of the link is recommending for the current user
    set previous-recommender [other-end] of max-one-of people-recommending [connection-strength]   ;; select the one with maximum link strength and set it as a previous recommender
    move-to [patch-here] of previous-recommender                                                   ;; teleport to the video that is shared by the connection user
  ]
end
;; view procedure
to view
  set is_recommending? false                                               ;; not sharing as of now
  let current-patch patch-here
  let current-video [video-id] of current-patch                            ;; get the video
  ifelse random-float 1 < 0.5 and member? current-video videos-viewed[     ;; if this video is not already watched by the current user, then with 50 % probability
    rt random 360                                                          ;; move in any random direction 1 step
    fd 1
  ]
  [
    set videos-viewed lput current-video videos-viewed                     ;; else watch the video again
    ask current-patch [
      set number-of-times-viewed number-of-times-viewed + 1                ;; update the watch count of the watched video
    ]

    decide-to-share-or-not                                                 ;; decide to share or not

  ]
end
;; procedure for sharing of videos
to decide-to-share-or-not
  let current-patch patch-here
  let current-video-sharing-likelihood ( item (video-type - 1) video-sharing-likelihood ) / 100               ;; getting the sharing likelihood of video on this patch
  let motivation-to-share [mean social-motivation-index] of current-patch / 5                                 ;; getting mean of social motivation index, and normalizing it by dividing by 5 as it can be between 1 to 5
  if my-sharing-likelihood * current-video-sharing-likelihood * motivation-to-share > random-float 1 [        ;; with probability my-sharing-likelihood * current-video-sharing-likelihood * motivation-to-share, share the video
    set is_recommending? true                                                                                 ;; since the user is sharing, set its is_recommending to true
    set total-times-shared total-times-shared + 1                                                             ;; increment the total times shared count
    set number-of-times-shared number-of-times-shared + 1                                                     ;; increment the number of times this video has been shared
    set sharing-rates replace-item (video-type - 1) sharing-rates ( item  (video-type - 1) sharing-rates + 1) ;; Change the sharing rate of this video
    if (previous-recommender != nobody ) [                                                                    ;; if there was a user who recommended this video to the current user
      ask link-with previous-recommender [                                                                    ;; ask the link between them
        set connection-strength connection-strength + 1                                                       ;; to increase its strength by 1
        set label connection-strength
      ]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
231
54
781
605
-1
-1
16.42424242424243
1
10
1
1
1
0
0
0
1
-16
16
-16
16
1
1
1
ticks
30.0

SLIDER
16
56
188
89
number-of-users
number-of-users
2
1000
250.0
1
1
NIL
HORIZONTAL

CHOOSER
19
179
157
224
social-graph-type
social-graph-type
"preferential" "smallworld" "random"
2

BUTTON
22
275
85
308
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
17
137
187
170
video-removal-rate
video-removal-rate
50
500
300.0
1
1
ticks
HORIZONTAL

SLIDER
17
93
187
126
video-removal-probability
video-removal-probability
0
0.2
0.05
0.01
1
NIL
HORIZONTAL

BUTTON
103
276
166
309
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
828
365
1294
658
Number of views ( different video types )
Video Type 
Number of views 
1.0
20.0
0.0
500.0
true
false
"" "clear-plot"
PENS
"default" 1.0 1 -16777216 true "" "foreach n-values 16 [ x -> x + 1] [ x -> plotxy x mean [number-of-times-viewed] of patches with [video-type = x] ]"

PLOT
1313
64
1855
367
Sharing Rates (different video types)
Time
Sharing Rate 
0.0
2000.0
0.0
0.5
true
true
"" ""
PENS
"Pets & Animals" 1.0 0 -2139308 true "" "plot ( item 0 sharing-rates / total-times-shared)"
"Nonprofits & Activism" 1.0 0 -817084 true "" "plot ( item 1 sharing-rates / total-times-shared)"
"News & Politics" 1.0 0 -5207188 true "" "plot ( item 2 sharing-rates / total-times-shared)"
"Travel & Events " 1.0 0 -987046 true "" "plot ( item 3 sharing-rates / total-times-shared)"
"Education" 1.0 0 -8732573 true "" "plot ( item 4 sharing-rates / total-times-shared)"
"Science & Technology" 1.0 0 -11085214 true "" "plot ( item 5 sharing-rates / total-times-shared)"
"Sports" 1.0 0 -14835848 true "" "plot ( item 6 sharing-rates / total-times-shared)"
"People & Blogs" 1.0 0 -8990512 true "" "plot ( item 7 sharing-rates / total-times-shared)"
"Autos & Vehicles" 1.0 0 -11033397 true "" "plot ( item 8 sharing-rates / total-times-shared)"
"Comedy" 1.0 0 -10649926 true "" "plot ( item 9 sharing-rates / total-times-shared)"
"HowTo & Style" 1.0 0 -6917194 true "" "plot ( item 10 sharing-rates / total-times-shared)"
"Entertainment" 1.0 0 -4699768 true "" "plot ( item 11 sharing-rates / total-times-shared)"
"Gadgets & Games" 1.0 0 -1664597 true "" "plot ( item 12 sharing-rates / total-times-shared)"
"Film & Animation" 1.0 0 -5325092 true "" "plot ( item 13 sharing-rates / total-times-shared)"
"Music" 1.0 0 -3425830 true "" "plot ( item 14 sharing-rates / total-times-shared)"
"Shows" 1.0 0 -2382653 true "" "plot ( item 15 sharing-rates / total-times-shared)"

PLOT
1360
379
1760
628
Total Shares and Views
NIL
NIL
0.0
3100.0
0.0
100000.0
true
true
"" ""
PENS
"Shares" 1.0 0 -16777216 true "" "plot total-times-shared"
"Views" 1.0 0 -3508570 true "" "plot sum [number-of-times-viewed ] of patches "

MONITOR
1998
110
2083
155
Max Degree
max [count link-neighbors] of turtles
17
1
11

MONITOR
2103
111
2178
156
Min Degree
min [count link-neighbors] of turtles
17
1
11

TEXTBOX
34
11
192
37
SETUP PARAMETERS
15
0.0
1

TEXTBOX
403
22
553
41
MODEL INTERFACE
15
0.0
1

TEXTBOX
1245
22
1518
60
PLOTS AND MONITORS
15
0.0
1

MONITOR
1865
111
1975
156
viewed vs shared
sum [number-of-times-viewed] of patches / total-times-shared
2
1
11

PLOT
830
65
1278
347
Music videos fraction as time progresses
ticks
Fraction of total views 
0.0
10.0
0.0
4.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot ( sum [number-of-times-viewed] of patches with [video-type = 15]) * 100 / sum [number-of-times-viewed ] of patches \n"

@#$#@#$#@
# Viral spread of different type of content on social media Model ODD Description

The model description follows the ODD (Overview, Design concepts, Details) protocol for describing individual and agent-based models (Grimm et al. 2006; 2010; Railsback and Grimm 2018)

## 1. Purpose and patterns
This model is designed to explore the spread of viral content on social media via the methods of diffusion of information. Using the model one can try to answer the following questions: 

* What kind of social network graph has what kind of effect on the sharing and virality of a video? 

* Which model is the real world social graph closest to? 

* What social factors and other factors contribute to a content or a video going viral?

* what pushes people to share, watch the content? 

* What interactions between content and user compels the users to watch the it? 

The model assumes that the strength of connectivity or trust between users is increased as they succesfully shares content among them. The model is based on real-world phenomenons, and thus, this model try to recreate the patterns of content-sharing and content-viewing found in the real world social media networks. These patterns will surely show some emergent patterns as well, allowing us to comment on various parameters which generated such patterns.  

## 2. Entities, State Variables, and Scales

There are three kind of entities: The turtles which represents the users on social media, the patches represents content (or video to be more specific), a network between users as links.  

The patches make up a square grid landscape of 33 x 33 patches with no wrapping around the edges and each patch has the following state variables: 

* video-type: A static variable, representing the type of the video/content. There are only 16 different video types, which are defined as follows:  
	* type 1: Pets and Animals
	* type 2: Nonprofits & Activism
	* type 3: News & politics
	* type 4: Travel & Events
	* type 5: Education
	* type 6: Science and Technology
	* type 7: Sports
	* type 8: People & Blogs
	* type 9: Autos & Vehicles
	* type 10: Comedy
	* type 11: Howto & style
	* type 12: Entertainment
	* type 13: Gadgets & Games
	* type 14 Film & Animation 
	* type 15: Music
	* type 16: Shows

Each video type has a sharing likelihood value, which is in accordance with the Broxton paper, cited in the references section. More on the sharing likelihood in initialization section. 

* video-id: A static varaible, contaning the id of the video/content. Each video has a unique id assigned to it. 

* number-of-times-viewed: A static variable, representig the number of times the content on this patch is viewed by the user. 

* social-motivation-index: A static list where each value of the list ranges from 1 to 5 and represents the social-emotion-index of a content/video. The social emotions are are of the following type (in order list entries): 
	* zeitgeist 
	* opinion-seeking
	* experience
	* perseverence
	* kudos
 	* social-welfare
	* reaction
	* expression
	* utility

Each turtle represents a user on social media and turtle has the following state variables: 

* videos-viewed: A dynamic list variable, containing id's of the content/video viewed by the user
 
* my-sharing-likelihood: A static variable which represents the sharing likelihood of a user, for the content/videos

* number-of-times-shared: A dynamic variable, representing the number of times any content/video has been shared by this user

* is_recommending? : A dynamic variable, representing if the user is open to share any content or not

* previous-recommender: A dynamic variable, representing the user(turtle) who immediately recommended some content to this user. It will be used to increase the trust between these users, by increasing the link strength. 

The network is formed by undirected links from one turtle to other turtle. Each link has a state variable "connection-strength", which represents the strength of connection between 2 users. 
 
Here, one time step isn't a defined value, but upon parameter calibration and comparing the patterns with the literature, it is found that 100 ticks represents a day, and the model runs for around 31 days or a month. 

## 3. Process Overview and Scheduling
The model includes the following actions that are executed in this order at each time step.

**View :** The user tries to view video at the location he is on ( the video on the patch the user is), if it has not already viewed the same video or randomly watches the video  again with a probabilty of 50%. Now, if the user watches the video, then it decides if it wants to share this video or not. 

	* **Deciding to share or not :**  Now for deciding if the user wants to share the video or not, the user evaluates the mean of the social-indexes of the video, and multiplies it with his likelihood of sharing the video, and the likelyhood of this video being shared and shares it with a random probabilty. If this video is shared, then the connection strength between the user who suggested this video to this user(previous-recommender) is increased by 1. 

However, if the user has already viewed the current-video (video represented by the patch on which user is present currently) then it randomly tries to reach some other content . This process is done via moving the user in some random direction on some other patch, as each patch is a different video. 

**Watch New Video :**  After viewing step, the user tries to watch a new video. To watch a new video, a user checks if there are any connections of it who are trying to share/recommend some video. If so, out of of all those users, it selects the user which it trusts the most (here trust is represented by connection(link) strength). Upon finding such a user, this user moves to the location where the video recommended by the sharer user is (this process is done by teleporting this user to the patch location of the sharer user). And the previous-recommender of the user who teleported is set to the user who shared the video. 

**Decide to remove :** After some regular interval of time (decided by the slider video-removal-rate) there is a chance that a video will be removed, and in place of deleted video, a new video will be added of the same type. The chance of deletion is also decided by a slider called video-removal-probablity. The process of creating a new video is covered in initialization part. 
When a video is removed, it is also removed from any place it was associated with. For example, from the viewed history of a user, or the number of times shared is decreased by the sharing count of deleted video.   

## 4. Design Concepts

* **Basic Principles :** The model is based on the basic theory of information diffusion and virality. The users interact with each other and perform actions based on their interaction with other users as well as the environment(patches). The purpose of this model is to study the variation of number of views, rates of sharing, etc depending on the type of the content and their likelihoods. 

* **Emergence :** There is an emergence of the number of content views distribution and their sharing rates depending on the type of video, and the social graph. The agents or the users simply interact with their environment and with other agents or users, and the out come is the emergent behavoious of these interactions. This emegrent behaviour is in accordance with the literature. 

* **Adaptation :**  The adaptive behavious of the users is to recommend content to other users and depending on the strength/ trust of their connection watch the content recommended by other users. At each time step, a user can decide if it wants to share some content to its connections or not. Also, it tries to watch a new video which has been recommended or shared by one of his connections, or to watch a old video. The agents depending on their interaction with a specific agent/user, increases their connection strength, which in turn helps it to see the best content (on an individual basis) based on recommendation by its connections.

* **Objective :** The goal or objective of a user is to maximize the worth of content watched per time spent. Thus a user will always try to see a content which is recommended by some one who it trusts the most, and who has social traits similar to it. Thus, when there are a lot of connection users recommending content to a user, then the target user always choses the user with the highest trust value or the highest connection strength value, and thus maximizing their pleasure per unit time, by viewing content that suits him/her the most. 

* **Learning :** There is no as such learning in the model.  

* **Prediction :** The model predicts the rate of sharing of content and average view of of different types of content. 
 
* **Sensing :**  The agents are assumed to know the agent who previously recommnended the conent it is watching, without error. Also, all the agents are assumed to know the connections strengths between their link neighbors without error . 

* **Interaction :**  Agents interact with the patches, and they can share the content at the current patch, and they can view the content at the current patch location. Also, the agents interact with themselves, where they can increase the connection strength between their link neighbors upon watching a recommended content by some link neighbor. 

* **Stochasticity :** The user social graph setup initally can also be chosen to be a random graph, which is set up stocastically. The setting up of a content's social parameters are set up randomly and thus are stocastic. The deletion of videos on every fixed interval of time is also stocastically done. After deletion, new videos are created to fill the place of the removed video. The social parameters for the videos are again set stocastically. 
The user agents are placed randomly on the world, and their sharing likelihood is choosen stocastically. The method to watch the video also has randomness in it as explained in section 3, and also the movement of turtles is done randomly. 
Thus the stocasticity is used to share and recommend the content to other link neighbors and define the view and sharing patterns in this model. 

* **Collectives :** There are no collectives in the model

* **Observation :** The Number of views plot shows the mean views of all the patches having the same content type. When a user watches any content this plot is updated. Similarly the total views vs total shares gives a plot between time and the total views and shares. 
The sharing rates line chart gives the sharing rates of different type of content vs time. Once a user shares a content, the sharing rates change. 


## 5. Initialization

Firstly a network is setup depending on the type of network selected and the links are setup. The connection-strength of each link is initialized to 1. 

Then turtles/users are created in the network. Their viewed list is set to empty ( [ ] ), their previous-recommender is set to nobody, their is_recommending? variable is set to false, their sharing likelihood is set to some random float between 0 and 1. 
Next the global variables are setup, namely 

* total-times-shared which is initialized to 1

* sharing-rates which is initialized to [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

* video-sharing-likelihood which is set to [42.3 38.8 31.7 29.5 28.8 28.4 28.1 26.7 23.8 20.0 19.7 15.6 15.3 14.0 12.8 9.8] depending on the Broxton paper, for the 16 video types in order mentioned in section 2.

* The social-motivation-types are set to ["zeitgeist" "opinion-seeking" "experience" "perseverence"  "kudos"  "social-welfare" "reaction" "expression" "utility"] depending on research of Phil Nottingham. 

After this step, the world is setup and the content is created. Each patch represents a video, and therefore, a unique ID is created for each patch where numbers from 1 to number-of-patches are assigned uniquely to each patch. 

The world is divided into 16 parts, each part representing a specific type of video (from Broxton Paper). Now, a new video is created for each patch. To do so, the video-i of video is set depending on the location of the patch (into one of the 16 types defined above). The social-motivation-index for each video is initialized to a random list of numbers, the number-of-times-viewed state variable is initialized to 0. Note, in the model interface, each of the 16 parts will have a number in the background with a different color indicating the type of the video present at that location.

Initialization is always the same, except the likelyhoods that are begin initialized randomly. 

## 6. Input Data

The model has no input data.

## 7. Submodels

*  **View Submodel :** The view submodel defines exactly how the users will watch a content and the sharing patterns of a user. The user will move to a new video patch randomly if it has already watched the content. All other actions are fully described in the section 3 above. 

* **Watch new video submodel :** The watch new video submodel is actually the part where sharing of the content occurs. This is the place, where a user will look for its most trusted connection/friend out of all those connections who are willing to share any content. And to watch the content shared to him/her, it has to move to the location of the video-patch shared to it. This step counts as the content being shared, and the sharing count of the content is increased. All other actions are fully described in the section 3 above. 

* **Decide to delete :** The decide to delete submodel will basically remove some content from the world regualarly on certain intervals of time. The removal of content is completely a random choice, with probability defined in the slider. After removal new content need to take place of the removed content. All other actions are fully described in the section 3 above. 

## CREDITS AND REFERENCES

* Tom Broxton, Yannet Interian, Jon Vaver, and Mirjam Wattenhofer. Catching a viral video. In ICDM'10 Workshop, pages 241--259, Los Alamitos, CA, USA, 2010. IEEE Computer Society.

* Phil Nottingham. Building a Social Video Strategy- WistiaFest 2015 
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1600"/>
    <metric>item 0 sharing-rates / total-times-shared</metric>
    <metric>item 1 sharing-rates / total-times-shared</metric>
    <metric>item 2 sharing-rates / total-times-shared</metric>
    <metric>item 3 sharing-rates / total-times-shared</metric>
    <metric>item 4 sharing-rates / total-times-shared</metric>
    <metric>item 5 sharing-rates / total-times-shared</metric>
    <metric>item 6 sharing-rates / total-times-shared</metric>
    <metric>item 7 sharing-rates / total-times-shared</metric>
    <metric>item 8 sharing-rates / total-times-shared</metric>
    <metric>item 9 sharing-rates / total-times-shared</metric>
    <metric>item 10 sharing-rates / total-times-shared</metric>
    <metric>item 11 sharing-rates / total-times-shared</metric>
    <metric>item 12 sharing-rates / total-times-shared</metric>
    <metric>item 13 sharing-rates / total-times-shared</metric>
    <metric>item 14 sharing-rates / total-times-shared</metric>
    <metric>item 15 sharing-rates / total-times-shared</metric>
    <steppedValueSet variable="number-of-users" first="50" step="100" last="500"/>
    <steppedValueSet variable="deletion-rate" first="50" step="100" last="500"/>
    <enumeratedValueSet variable="deletion-probability">
      <value value="0.01"/>
      <value value="0.02"/>
      <value value="0.04"/>
      <value value="0.05"/>
      <value value="0.08"/>
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;small-world&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>[number-of-times-viewed] of patch -6 3 - views-per-day</metric>
    <enumeratedValueSet variable="social-graph-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="video-removal-rate">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-users">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="video-removal-probability">
      <value value="0.05"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>item 0 sharing-rates / total-times-shared</metric>
    <metric>item 1 sharing-rates / total-times-shared</metric>
    <metric>item 2 sharing-rates / total-times-shared</metric>
    <metric>item 3 sharing-rates / total-times-shared</metric>
    <metric>item 4 sharing-rates / total-times-shared</metric>
    <metric>item 5 sharing-rates / total-times-shared</metric>
    <metric>item 6 sharing-rates / total-times-shared</metric>
    <metric>item 7 sharing-rates / total-times-shared</metric>
    <metric>item 8 sharing-rates / total-times-shared</metric>
    <metric>item 9 sharing-rates / total-times-shared</metric>
    <metric>item 10 sharing-rates / total-times-shared</metric>
    <metric>item 11 sharing-rates / total-times-shared</metric>
    <metric>item 12 sharing-rates / total-times-shared</metric>
    <metric>item 13 sharing-rates / total-times-shared</metric>
    <metric>item 14 sharing-rates / total-times-shared</metric>
    <metric>item 15 sharing-rates / total-times-shared</metric>
    <enumeratedValueSet variable="social-graph-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="video-removal-rate">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-users">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="video-removal-probability">
      <value value="0.05"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@