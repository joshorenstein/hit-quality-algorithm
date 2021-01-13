
This hit quality algorithm categorizes MLB contacts into 7 different types based on launch velocity and launch angle. For this algorithm four supervised machine learning models were tested, Regresion Trees, Bagged Regression Trees, Support Vector Machine, and Naive Bayes. Naive Bayes performed the best and could be used to classify future contacts. In the beginning stages of the modeling process, hierarchical clustering, an unsupervised machine learning algorithm, was used to label the data. The purpose of the hierarchical clustering model is to simply label the data so that we can use the more robust algorithms available in supervised machine learning. 

Average Speed and Angle for the 7 hit types identified
Hard_Air_Contact: 100.3 MPH, 15 Launch Angle, Est WOBA: .702
Fliner: 76.4 MPH, 6.8 Launch, Est WOBA: .358


Naive_Bayes	        launch_speed	launch_angle	est_ba	est_woba
Hard_Air_Contact	      100.3	        15.0	      .573	.702
Fliner	                76.4	        6.8	        .388	.358
Soft_Air_Contact	      68.3	        42.7	      .328	.308
Very_Soft_Air_Contact	  44.0	        25.3	      .189	.196
Hard_Ground_Contact	    90.0	        -16.7	      .160	.149
Soft_Ground_Contact	    64.5	        -29.9	      .105	.097
High_Fly	              85.7	        47.7	      .043	.052
