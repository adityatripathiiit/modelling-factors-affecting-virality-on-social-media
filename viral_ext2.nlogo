extensions [ nw ]

globals [
  sharing-rates
  total-times-shared
  video-sharing-likelihood
  social-motivation-types
]

turtles-own [
  videos-viewed
  my-sharing-likelihood
  number-of-times-shared
  is_recommending?
  previous-recommender
]

links-own[ connection-strength ]

patches-own [
  video-type
  video-id
  shared-by
  number-of-times-viewed
  motivation-index
]

to setup
  clear-all
  set-parameters
  create-content
  create-network
  reset-ticks
end

to set-parameters
   set total-times-shared 1
   set sharing-rates [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
   set video-sharing-likelihood [42.3 38.8 31.7 29.5 28.8 28.4 28.1 26.7 23.8 20.0 19.7 15.6 15.3 14.0 12.8 9.8]
   set social-motivation-types ["shared-passion" "social-irl" "social-utility" "social-good" "zeitgeist" "kudos" "reaction-seeking" "self-expression" "shared-emotional-experience"]

end

to create-content
  (foreach (sort patches ) (n-values count patches [t -> t])[ [x y] -> ask x [set video-id y] ])
  ask patches [ create-one-video]
  color-regions
end

to create-one-video
  set motivation-index ( list  (random 5 + 1) (random 5 + 1) (random 5 + 1) (random 5 + 1) (random 5 + 1) (random 5 + 1) (random 5 + 1) (random 5 + 1) (random 5 + 1) )
  set number-of-times-viewed 0
  set shared-by nobody
  divide-world

end

to divide-world
if pxcor <= -8 and pxcor >= -16 and pycor <= 16 and pycor >= 8 [ set video-type 1 ]
  if pxcor <= -8 and pxcor >= -16 and pycor <= 8 and pycor >= 0 [ set video-type 2 ]
  if pxcor <= 0 and pxcor >= -8 and pycor <= 16 and pycor >= 8 [ set video-type 3 ]
  if pxcor <= -8 and pxcor >= -16 and pycor <= 0 and pycor >= -8 [ set video-type 4 ]
  if pxcor <= 0 and pxcor >= -8 and pycor <= 8 and pycor >= 0 [ set video-type 5 ]
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

to color-regions
  ask patches [
    set pcolor 6 + video-type * 10
    set plabel-color pcolor + 1
    set plabel video-type
    if(video-type = 14) [set pcolor 108 set plabel-color pcolor + 1]
    if(video-type = 15) [set pcolor 118 set plabel-color pcolor + 1]
    if(video-type = 16) [set pcolor 128 set plabel-color pcolor + 1]
  ]
end

to create-network
  if network-type = "random" [  nw:generate-random turtles links number-of-users 0.1 ]
  if network-type = "preferential" [ nw:generate-preferential-attachment turtles links number-of-users 1 ]
  if network-type = "small-world" [ let sq sqrt number-of-users nw:generate-small-world turtles links sq sq 2.0 false ]
  setup-links
  ask turtles [
    set shape "person"
    set color cyan + 3
    setxy random-xcor random-ycor
    set videos-viewed []
    set my-sharing-likelihood random 100 / 100
    set previous-recommender nobody
    set is_recommending? false
  ]
end


to setup-links ;link procedure
  ask links [
    set connection-strength 1
    set label connection-strength
  ]
end

to go
  ask turtles  [
    view
    see-new-video
  ]
  if( ticks != 0 and ticks mod deletion-rate = 0 ) [
    decide-to-delete
  ]

  tick
end

to decide-to-delete

  let to-delete []
  ask patches [
    if random-float 1 < deletion-probabilty [
      set to-delete lput video-id to-delete
      create-one-video
    ]
  ]
  foreach to-delete [
      t ->
      ask turtles [
        if member? t videos-viewed [
          set videos-viewed remove t videos-viewed
        ]
      ]
    ]
end

to see-new-video
  let people-recommending my-links with  [[ is_recommending?] of other-end]
  if( any? people-recommending) [
    set previous-recommender [other-end] of max-one-of people-recommending [connection-strength]
    move-to [patch-here] of previous-recommender
  ]
end

to view
  set is_recommending? false
  let current-patch patch-here
  let current-video [video-id] of current-patch
  ifelse random-float 1 < 0.5 and member? current-video videos-viewed[
    rt random 360
    fd 1

  ]
  [
    set videos-viewed lput current-video videos-viewed

    ask current-patch [
      set number-of-times-viewed number-of-times-viewed + 1
    ]

    decide-to-share-or-not

  ]
end

to decide-to-share-or-not
  let current-patch patch-here
  let current-video-sharing-likelihood ( item (video-type - 1) video-sharing-likelihood ) / 100
  let motivation-to-share [mean motivation-index] of current-patch / 5

  if my-sharing-likelihood * current-video-sharing-likelihood * motivation-to-share > random-float 1 [
    set shared-by self
    set is_recommending? true
    set total-times-shared total-times-shared + 1
    set number-of-times-shared number-of-times-shared + 1
    set sharing-rates replace-item (video-type - 1) sharing-rates ( item  (video-type - 1) sharing-rates + 1)

    if (previous-recommender != nobody ) [
      ask link-with previous-recommender [
        set connection-strength connection-strength + 1
        set label connection-strength
      ]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
305
13
855
564
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
0
0
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
100
1000
250.0
1
1
NIL
HORIZONTAL

CHOOSER
16
96
154
141
network-type
network-type
"preferential" "small-world" "random"
0

BUTTON
20
331
83
364
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
15
155
187
188
deletion-rate
deletion-rate
50
500
300.0
1
1
ticks
HORIZONTAL

SLIDER
12
196
184
229
deletion-probabilty
deletion-probabilty
0
0.2
0.05
0.01
1
NIL
HORIZONTAL

BUTTON
101
332
164
365
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
937
40
1314
293
Number of views ( different video types )
Video Type 
Number of views 
1.0
16.0
0.0
500.0
true
false
"" "clear-plot"
PENS
"default" 1.0 1 -16777216 true "" "foreach n-values 16 [ x -> x + 1] [ x -> plotxy x mean [number-of-times-viewed] of patches with [video-type = x] ]"

PLOT
930
321
1442
652
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

@#$#@#$#@
Opinion seeking
Shared passion
Social in real life
Social Utility
Kudos: Coolhunter 
Kudos: Authority
Zeitgeist 
Conversation starting
Self-Expression
Social good

https://melmarketingtips.com/blog/hello-world/

building-a-social-video-strategy-wistiafest-2015


model references: 
virus on a network
for division 
many regions
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
