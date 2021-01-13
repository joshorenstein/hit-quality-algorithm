This hit quality algorithm categorizes hits into 7 different hit types based on launch velocity and launch angle.. It uses hierarchical clustering, an unsupervised machine learning algorithm to initially label the data. Using the labeled data, the accuracy of the model is improved upon through the use of the more robust algorithms available in supervised machine learning. For this algorithm four models were tested, Regresion Trees, Bagged Regression Trees, Support Vector Machine, and Naive Bayes. Naive Bayes performed the best and could be used to classify future contacts.

Average Speed and Angle for the 7 hit types identified

Naive_Bayes	        launch_speed	launch_angle	est_ba	est_woba
Hard_Air_Contact	      100.3	        15.0	      .573	.702
Fliner	                76.4	        6.8	        .388	.358
Soft_Air_Contact	      68.3	        42.7	      .328	.308
Very_Soft_Air_Contact	  44.0	        25.3	      .189	.196
Hard_Ground_Contact	    90.0	        -16.7	      .160	.149
Soft_Ground_Contact	    64.5	        -29.9	      .105	.097
High_Fly	              85.7	        47.7	      .043	.052
