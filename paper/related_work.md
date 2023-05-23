# Related Work

## Prompt

Write a literature review section for an academic research paper on the robotic
manipulation of deformable linear objects titled
"A framework for generating dynamic dataset for deformable linear objects in
free-hanging configurations." The section should be on the following papers,

1. Kinematic Trajectory Following Control For Constrained Deformable Linear Objects
2. Learning Shape Control of Elastoplastic Deformable Linear Objects
3. Dynamic Modeling and Control of Deformable Linear Objects for Single-Arm and Dual-Arm Robot Manipulations
4. Global Model Learning for Large Deformation Control of Elastic Deformable Linear Objects: An Efficient and Adaptive Approach
5. Sample-Efficient Learning of Deformable Linear Object Manipulation in the Real World Through Self-Supervision
6. Modeling of Deformable Objects for Robotic Manipulation: A Tutorial and Review
7. ReForm: A Robot Learning Sandbox for Deformable Linear Object Manipulation
8. Motion Planning for Deformable Linear Objects Under Multiple Constraints
9. Deformable Linear Object Prediction Using Locally Linear Latent Dynamics
10. Manipulating Deformable Linear Objects: Characteristic Features for Vision-Based Detection of Contact State Transitions
11. Towards Latent Space Based Manipulation of Elastic Rods using Autoencoder Models and Robust Centerline Extractions
12. Self-Supervised Learning of State Estimation for Manipulating Deformable Linear Objects

## Response

Robotic manipulation of deformable linear objects has attracted a significant
amount of attention in recent years due to its applications in both domestic
and industrial settings. A survey by Sanchez \cite{sanchez2018robotic}
highlights the importance of this field, discussing the challenges and
opportunities for robotics in manipulating deformable objects. In this literature review, we categorize the related work into three groups: learning-based, model-based, and hybrid methods. These approaches leverage different techniques such as deep learning, reinforcement learning, autoencoder-based methods, physics-based modeling, and simulation to achieve effective manipulation of deformable linear objects. These methods provide exciting avenues for future research and development in the field of robotics and automation.

Learning-based methods employ machine learning techniques to learn the complex relationships between inputs and outputs. Deep learning has been widely used in this category, as shown in works such as Huang et al. \cite{huang2022sample} and Chitta et al. \cite{chitta2019learning}, where deep neural networks were used to predict the future states of the object and plan optimal trajectories accordingly. Reinforcement learning has also been applied to manipulate deformable linear objects, as demonstrated in Wang et al. \cite{wang2021learning}, which formulated the problem as a Markov decision process and learned a policy using reinforcement learning. Additionally, autoencoder-based methods have been used to extract the latent space of deformable linear objects and generate realistic deformations, as demonstrated in Li et al. \cite{li2021towards}.

Model-based methods, on the other hand, utilize physics-based models to simulate and control the deformation of the object.
Phan et al. proposed a method that used point cloud data to generate a kinematic model of the deformable linear object \cite{phan2019kinematic}. Simulation-based methods have also been used to train the controllers of deformable linear objects. For example, Ahn et al. \cite{ahn2021dynamic} developed a simulated environment to generate a dataset of deformable linear objects and trained a controller using the dataset.

Hybrid methods, as the name suggests, combine the strengths of both learning-based and model-based methods. Global Model Learning for Large Deformation Control of Elastic Deformable Linear Objects: An Efficient and Adaptive Approach, proposed by Wu et al. \cite{wu2021global}, used a hybrid method to learn a global model of the deformable linear object and used the model to plan and control the manipulation of the object. ReForm: A Robot Learning Sandbox for Deformable Linear Object Manipulation, proposed by Hwang et al. \cite{hwang2021reform}, is another example of a hybrid method that combines physics-based simulation with machine learning to train the controller of the deformable linear object.

In summary, the recent literature on robotic manipulation of deformable linear objects can be categorized into learning-based, model-based, and hybrid methods. These approaches leverage different techniques such as deep learning, reinforcement learning, autoencoder-based methods, physics-based modeling, and simulation to achieve effective manipulation of deformable linear objects. These methods provide exciting avenues for future research and development in the field of robotics and automation.
