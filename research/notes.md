%
\section{Research Proposal}
%
\textbf{Intro}\\

I propose a mathematical framework for system identification, state estimation, and real-time control of deformable linear objects (DLOs), e.g., cables. The proposed approach contrasts end-to-end learning-based methods, which have shown promising results in recent years. Learning-based models are usually trained for specific tasks and involve one or a small set of DLOs. They require a sizeable task-specific dataset, high-performance computing (HPC) resources, and extended training time. Moreover, learning-based models often do not generalize well to other DLOs or tasks. They require time-consuming and computationally expensive retraining with a new annotated dataset or reinforcement learning environment.

In recent years, manipulation and sensing of deformable objects have become a topic of interest among researchers, with applications in various industries, e.g., surgical robotics, food handling, and manufacturing [1].
Robotic manipulation of deformable objects remains particularly challenging, as they exhibit strongly nonlinear dynamics when subject to external forces. Although researchers have successfully introduced various learning-based methods for manipulating DLOs, the manipulation of deformable objects has remained mostly manual, causing industrial and economic bottlenecks. However, a new paradigm is emerging from data analysis and fluid dynamics research; data-driven modeling offers superior techniques for extracting explicit low-rank representations of complex systems from high-dimensional measurements [2, 3]. This proposal considers a framework for system identification, configuration estimation, and control of Kirchhoff elastic rods or DLOs, e.g., cables and ropes, using state-of-the-art data-driven modeling techniques. Physics-informed dynamic mode decomposition (piDMD) and Koopman operator theory provide a promising theoretical foundation in support of model predictive control (MPC) of DLOs [4 - 6]. If successful, this method could extend to address a wide range of open challenges in academia and industry, making new categories of manipulation tasks available for automation.

\textbf{Related work}\\
[too long]
Various approaches have been introduced for the quasi-static manipulation of DLOs, limiting manipulation tasks to low-speed movements. Bretl and McCarthy introduced a sampling-based path-planning method for dual-arm DLO manipulation tasks where grippers hold the object at both ends. They showed that a DLO in static equilibrium is a local solution to a geometric optimal control problem, the position and orientation of grippers dictate the boundary conditions. Using optimal control on manifolds and Lie-Poisson reduction, they prove that the set of all equilibrium is a smooth manifold of finite dimensions. They analytically proved that DLO dynamics is a smooth left-invariant Hamiltonian system in a dual-arm configuration that can be represented explicitly in 6 dimensions using a dual-basis functions approach[7]. Although such dimensionality reduction of DLO dynamics is remarkable, this approach is strictly limited to dual-arm configuration and slow-speed motions. Furthermore, different DLOs exhibit various degrees of elastoplasticity over different intrinsic dimensions; a systematic approach for extracting the intrinsic coherent structures from observations would offer better generalization to other DLO as it eliminates cumbersome analytical derivations. This proposal seeks a more general and systematic approach for obtaining the rank and the basis functions that are the best linear approximation of the data.

[DL methods]
Many learning-based methods operate under a similar quasi-static assumption; they learn a discrete state-action mapping to find the optimal sequence of actions, given an initial condition and a goal state. Zhang used an auto-encoder-decoder architecture to map nonlinear states and actions to their corresponding linear latent spaces. Then, they trained a linear dynamic model in the latent space to learn the mapping between [or the latent state prior?] the latent prior state, the latent action, and the latent posterior state [8]. Although this method learns a linear operator in the latent space that successfully predicts up to 10 future states, the dynamic mapping is purely statistical, locally linear, and heavily dependent on the provided training set. Even though autoencoders are a powerful tool for dimensionality reduction, they encode input data to a specified rank and only use a polynomial basis function.

[keep short for all DL methods][add shape control paper]
There are other deep learning methods for dual-arm and free-end DLO manipulation tasks that leverage a variety of techniques, e.g., movement primitives, model-free reinforcement learning, contrastive learning, and dense object descriptor, but they all have similar limitations.

Method and hypothesis
I propose PIKO: Physics-Informed Koopman Operator for real-time state estimation and control of dynamical systems with strong nonlinearities. It can extend to other nonlinear systems, i.e., 2D and 3D deformable objects.

PIKO is based on dynamic mode decomposition (DMD), physics-informed DMD (piDMD), the Koopman operator theory, and Hamiltonian mechanics [DMD, piDMD, Koopman]. DMD is a dimensionality reduction technique that extracts low-rank modal structures from high-dimensional time-series data. More specifically, DMD identifies the leading-order spatial eigenmodes of the system and the corresponding linear operators expressing how the amplitudes of these modes evolve in time.
DMD produces the full-ranked matrix A, which is, in fact, a Koopman operator. piDMD extends DMD by integrating five fundamental Newtonian physics principles, i.e., shift-invariant, conservative, self-adjoint, local, and causal, as computational constraints to obtain a representative model that is more in agreement with the known physics. Moreover, applying such constraints reduces computational load by reducing the searchable solution space. The resultant model should be numerically more stable.
The Koopman operator theorizes that a linear operator can represent the evolution of a nonlinear dynamical system by lifting the system representation to an infinite-dimensional Hilbert space. However, DLOs exhibit strong nonlinear dynamics and are challenging to model explicitly, especially from observed data and under noisy conditions. Moreover, A short DLO with homogeneous physical properties, such as a cable, is a Hamiltonian time-invariant system.

Deformable objects store energy by bending and twisting as external forces act on them. Once free from external forces, deformable objects release kinetic energy and move toward the nearest equilibrium or lowest-energy configuration. Consider a short DLO, whose dynamics are
Conversely, long DLOs behave more like fluids as their mass coefficients dominate the dynamics when moving at low speeds. Long DLOs have more pronounced dynamics at high speeds, and the mass distribution bifurcates to maintain stability when input energy increases.

High-dimensional state observations are arranged as a series of state prior and posterior pairs to form the corresponding Hamiltonian flow.
We are interested in the performance surface of the DLO.
This is important because we are capitalizing on the assumption that DLOs are inherently time-invariant Hamiltonian systems;
even though visual observations and subsequent DLO configuration estimation will be noisy.

\section{References}

[1] Sanchez, Jose, et al. "Robotic manipulation and sensing of deformable objects in domestic and industrial applications: a survey." The International Journal of Robotics Research 37.7 (2018): 688-716.

%DDM
[2] Kutz, J. Nathan. Data-driven modeling \& scientific computation: methods for complex systems & big data. Oxford University Press, 2013.

%DMDc
[3] Proctor, Joshua L., Steven L. Brunton, and J. Nathan Kutz. "Dynamic mode decomposition with control." SIAM Journal on Applied Dynamical Systems 15.1 (2016): 142-161.

%DMD
[4] Schmid, Peter J. "Dynamic mode decomposition of numerical and experimental data." Journal of fluid mechanics 656 (2010): 5-28.

%piDMD
[5] Baddoo, Peter J., et al. "Physics-informed dynamic mode decomposition (piDMD)." arXiv prlogging.error arXiv:2112.04307 (2021).

%Koopman
[6] Mezić, Igor. "Koopman operator, geometry, and learning of dynamical systems." Notices of the American Mathematical Society 68.7 (2021): 1087-1105.

%Quasi-static manipulation of DLO
[7] Bretl, Timothy, and Zoe McCarthy. "Quasi-static manipulation of a Kirchhoff elastic rod based on a geometric analysis of equilibrium configurations." The International Journal of Robotics Research 33.1 (2014): 48-68.

%AE DLO Locally Linear latent Dynamics
[8] Zhang, Wenbo, et al. "Deformable linear object prediction using locally linear latent dynamics." 2021 IEEE International Conference on Robotics and Automation (ICRA). IEEE, 2021.

\documentclass[letterpaper,10pt,conference]{ieeeconf}
%\documentclass[letterpaper,10pt,journal,twoside]{ieeetran}
\IEEEoverridecommandlockouts
\overrideIEEEmargins
\usepackage{algorithm}
\usepackage{algorithmic}
\usepackage{amsfonts}
\usepackage{amsmath}
\usepackage{amssymb}
\usepackage{array}
\usepackage{bm}
\usepackage{breakcites}
\usepackage{color}
\usepackage{comment}
\usepackage{float}
\usepackage{gensymb}
\usepackage{graphicx}
\usepackage{multirow}
\usepackage{mycomments}
\usepackage{pdfpages}
\usepackage{pgfplots}
\usepackage[caption=false,font=footnotesize,subrefformat=parens,labelformat=parens]{subfig}
\usepackage{textcomp}
\usepackage{tikz}
\usepackage{pgfplots}
\usepackage{wrapfig}
\usepackage{xcolor}
\usepackage{tabularx}

\PassOptionsToPackage{hyphens}{url}\usepackage[breaklinks=true,hidelinks=true]{hyperref}

\graphicspath{{figures/}}

\def\commenton{1} % Comment out this line to hide comments
\def\editon{1} % Comment out this line to hide deletions and coloring of additions
\newcommand{\centered}[1]{\begin{tabular}{l} #1 \end{tabular}}

\DeclareMathOperator*{\argmax}{arg\,max}
\DeclareMathOperator*{\argmin}{arg\,min}

\definecolor{dargreen}{rgb}{0.0, 0.5, 0.0}

% Update title as needed
\title{Deformable Linear Objects: Real-Time System Identification and
Low-Dimensional Dynamics Representation}

\author{Bardia Mojra, Christopher Collander, Maicol Zayas Melendez, Nicholas R. Gans, and William J. Beksi
\thanks{B. Mojra, C. Collander, M. Z. Melendez, and W.J. Beksi are with the Department of Computer Science and
Engineering, The University of Texas at Arlington, Arlington, TX, USA.
N.R. Gans is with The University of Texas at Arlington Research
Institute, Fort Worth, TX, USA.
Emails:
bardia.mojra@mavs.uta.edu,
christopher.collander@mavs.uta.edu,
maicol.zayasmelendez@mavs.uta.edu,
nick.gans@uta.edu,
william.beksi@uta.edu.
}
}

\begin{document}
\maketitle
\pagestyle{plain}

\begin{abstract}
We present a novel dataset for real-time system identification, control,
and manipulation of deformable linear objects (DLOs), i.e., cables and hoses.
This dataset aims to disambiguate DLO dynamics from all factors and allow for
the real-time system identification of

\end{abstract}

\begin{keywords}
%RGB-D Perception;
%Deep Learning Methods;
%Deep Learning for Visual Perception;
%Big Data in Robotics and Automation
\end{keywords}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Introduction}
\label{sec:introduction}
%\begin{figure}[t]
%\centering
%\includegraphics[scale=0.90]{}
%\caption{
%}
%\label{fig:}
%\end{figure}
% ------>> applications
% ------>> DLO research tasks
% ------>> problem statement and relate to RW
% ------\--->>> DLOs: briefly define DLO and what should be considered a DLO
% ------\--->>> DLO manipulation tasks -- ignore
% ------\--->>> DLO Datasets: shortcomings? and why we chose simulation
% ------\--->>> DLO Dynamics and Deformation models

% ------>> recent work and relate to RW
% ------\--->>> General state of the problem
% ------>> what is presented in this <https://github.com/BardiaMojra/dlo.gitpaper>
% ------>> how it is presented in this paper (org of paper)
%
%

I propose a mathematical framework for system identification, state estimation, and real-time control of deformable linear objects (DLOs), e.g., cables. The proposed approach contrasts end-to-end learning-based methods, which have shown promising results in recent years. Learning-based models are usually trained for specific tasks and involve one or a small set of DLOs. They require a sizeable task-specific dataset, high-performance computing (HPC) resources, and extended training time. Moreover, learning-based models often do not generalize well to other DLOs or tasks. They require time-consuming and computationally expensive retraining with a new annotated dataset or reinforcement learning environment.

In recent years, manipulation and sensing of deformable objects have become a topic of interest among researchers, with applications in various industries, e.g., surgical robotics, food handling, and manufacturing [1].
Robotic manipulation of deformable objects remains particularly challenging, as they exhibit strongly nonlinear dynamics when subject to external forces. Although researchers have successfully introduced various learning-based methods for manipulating DLOs, the manipulation of deformable objects has remained mostly manual, causing industrial and economic bottlenecks. However, a new paradigm is emerging from data analysis and fluid dynamics research; data-driven modeling offers superior techniques for extracting explicit low-rank representations of complex systems from high-dimensional measurements [2, 3]. This proposal considers a framework for system identification, configuration estimation, and control of Kirchhoff elastic rods or DLOs, e.g., cables and ropes, using state-of-the-art data-driven modeling techniques. Physics-informed dynamic mode decomposition (piDMD) and Koopman operator theory provide a promising theoretical foundation in support of model predictive control (MPC) of DLOs [4 - 6]. If successful, this method could extend to address a wide range of open challenges in academia and industry, making new categories of manipulation tasks available for automation.

\textbf{Related work}\\
[too long]
Various approaches have been introduced for the quasi-static manipulation of DLOs, limiting manipulation tasks to low-speed movements. Bretl and McCarthy introduced a sampling-based path-planning method for dual-arm DLO manipulation tasks where grippers hold the object at both ends. They showed that a DLO in static equilibrium is a local solution to a geometric optimal control problem, the position and orientation of grippers dictate the boundary conditions. Using optimal control on manifolds and Lie-Poisson reduction, they prove that the set of all equilibrium is a smooth manifold of finite dimensions. They analytically proved that DLO dynamics is a smooth left-invariant Hamiltonian system in a dual-arm configuration that can be represented explicitly in 6 dimensions using a dual-basis functions approach[7]. Although such dimensionality reduction of DLO dynamics is remarkable, this approach is strictly limited to dual-arm configuration and slow-speed motions. Furthermore, different DLOs exhibit various degrees of elastoplasticity over different intrinsic dimensions; a systematic approach for extracting the intrinsic coherent structures from observations would offer better generalization to other DLO as it eliminates cumbersome analytical derivations. This proposal seeks a more general and systematic approach for obtaining the rank and the basis functions that are the best linear approximation of the data.

[DL methods]
Many learning-based methods operate under a similar quasi-static assumption; they learn a discrete state-action mapping to find the optimal sequence of actions, given an initial condition and a goal state. Zhang used an auto-encoder-decoder architecture to map nonlinear states and actions to their corresponding linear latent spaces. Then, they trained a linear dynamic model in the latent space to learn the mapping between [or the latent state prior?] the latent prior state, the latent action, and the latent posterior state [8]. Although this method learns a linear operator in the latent space that successfully predicts up to 10 future states, the dynamic mapping is purely statistical, locally linear, and heavily dependent on the provided training set. Even though autoencoders are a powerful tool for dimensionality reduction, they encode input data to a specified rank and only use a polynomial basis function.

[keep short for all DL methods][add shape control paper]
There are other deep learning methods for dual-arm and free-end DLO manipulation tasks that leverage a variety of techniques, e.g., movement primitives, model-free reinforcement learning, contrastive learning, and dense object descriptor, but they all have similar limitations.

Method and hypothesis
I propose PIKO: Physics-Informed Koopman Operator for real-time state estimation and control of dynamical systems with strong nonlinearities. It can extend to other nonlinear systems, i.e., 2D and 3D deformable objects.

PIKO is based on dynamic mode decomposition (DMD), physics-informed DMD (piDMD), the Koopman operator theory, and Hamiltonian mechanics [DMD, piDMD, Koopman]. DMD is a dimensionality reduction technique that extracts low-rank modal structures from high-dimensional time-series data. More specifically, DMD identifies the leading-order spatial eigenmodes of the system and the corresponding linear operators expressing how the amplitudes of these modes evolve in time.
DMD produces the full-ranked matrix A, which is, in fact, a Koopman operator. piDMD extends DMD by integrating five fundamental Newtonian physics principles, i.e., shift-invariant, conservative, self-adjoint, local, and causal, as computational constraints to obtain a representative model that is more in agreement with the known physics. Moreover, applying such constraints reduces computational load by reducing the searchable solution space. The resultant model should be numerically more stable.
The Koopman operator theorizes that a linear operator can represent the evolution of a nonlinear dynamical system by lifting the system representation to an infinite-dimensional Hilbert space. However, DLOs exhibit strong nonlinear dynamics and are challenging to model explicitly, especially from observed data and under noisy conditions. Moreover, A short DLO with homogeneous physical properties, such as a cable, is a Hamiltonian time-invariant system.

Deformable objects store energy by bending and twisting as external forces act on them. Once free from external forces, deformable objects release kinetic energy and move toward the nearest equilibrium or lowest-energy configuration. Consider a short DLO, whose dynamics are
Conversely, long DLOs behave more like fluids as their mass coefficients dominate the dynamics when moving at low speeds. Long DLOs have more pronounced dynamics at high speeds, and the mass distribution bifurcates to maintain stability when input energy increases.

High-dimensional state observations are arranged as a series of state prior and posterior pairs to form the corresponding Hamiltonian flow.
We are interested in the performance surface of the DLO.
This is important because we are capitalizing on the assumption that DLOs are inherently time-invariant Hamiltonian systems;
even though visual observations and subsequent DLO configuration estimation will be noisy.

%
\subsection{Deformable Linear Objects [soft intro]}

In recent years, real-time robotic manipulation of deformable linear objects (DLOs) has
become increasingly sought after in industrial manufacturing,
agriculture and consumer robotics sectors ~\cite{khalil2010dexterous,sanchez2018robotic}.
Researcher community has been generally successful at real-time manipulation of rigid-body
objects, but we can not claim the same for deformable objects \cite{billard2019trends}.
While a considerable portion of all objects are deformable and their manipulation remains
an open problem; we are greatly limited in terms
of applications where a robotic manipulator could be deployed. Manipulation of deformable
objects, especially in real-time and under high uncertainty, is a vastly greater challenge
than performing the same task for rigid objects. This is because deformable objects
have time-invariant dynamic mass instead of a rigid-body mass which, is simply represented by
a point-mass at center of object's mass.
Mass-spring models are of interest to us since they offer relatively low-dimensional
multi-body dynamical representation, high computational efficiency, and accurate prediction
of near-future state. This is particularly desirable to us since it closely simulates
\emph{strong nonlinearities} and \emph{chaotic behavior} exhibited by real
world DLOs. In this paper, we investigate real-time system identification, obtain persistent dynamics with
\emph{Physics Informed} constraints, and model validation through pose estimation of DLO configuration in a dual-arm manipulation setting.\\

% deformable objects
\subsection{Deformable Linear Objects [setting]}
A large percentage of
objects are considered \emph{deformable}; they change shape and can store energy
(stresses and strains) when subjected to exogenous input (loading condition).
Broadly, these characteristics are described as \emph{object dynamics} as they
resemble dynamical systems.
Generally, deformable objects are categorized into three, linear (1D),
planar (2D), and volumetric (3D). In this paper, we focus on defromable linear
objects (DLOs), or elastic rods as we aim to model a low-dimensional and
presistent representation for their dynamics in real-time. \\
Recently, various methods have been introduced for reprenting DLO dynamics
but suffer from poor generalization since
numerical and geometric models do not properly capture nonlinear nature of DLO
dynamics \cite{arriola2020modeling}. \\

% deformable objects
\subsection{DLO System Identification [problem statement]}
The challenge regarding manipulation and precise control of DLOs is rooted in
strong nonlinearities exhibited by the object and lack of efficient and
effective techniques for modeling it dynamics.
Once an explicit model is obtained, various
well-established model-based control techniques could be deployed to achieve
robust or optimal control in real-time. Model-based approaches often make
constraining assumptions that significantly reduces model dimensions and
over simplify physical attributes. This results in models
that often underperform when application setting does not satisfy the original
model assumptions \cite{bruder2020data}. For instance,

On the other hand, learning-based methods generalize well but they are
computationally

Various model-based
and learning methods have been introduced in the literature that are able to
make state predictions and manipulate a DLO in real-time.

\subsection{Koopman Operator}
% estimation and control
Although it was originally developed in 1932 there has been a new interest in using
\emph{the Koopman operator} as
method for modeling highly dynamic systems with strong nonlinearities.
The Koopman operator\

I researched Koopman operator, dynamic mode decomposition (DMD)
\cite{kutz2016dynamic} \cite{schmid2010dynamic},
extended dynamic mode decomposition (EDMD) \cite{williams2015data},
Hankel alternative view of Koopman (HAVOK) \cite{brunton2017chaos}, and
sparse identification of nonlinear dynamic systems (SiNDy) \cite{brunton2016discovering}.
All these methods are very similar in principle as they combine principal
component analysis (PCA) with frequency analysis to represent system or data
dynamics with respect to both time and space. Each of the mentioned methods
slightly differ from each other. For example, HAVOK and Koopman are low
dimensional where DMD and EDMD are high dimensional methods. Koopman and
HAVOK are continuous where SinDy is sparse. I will test all these methods
and present the results in my DLO paper. \\

\subsection{Dynamics Mode Decomposition}

\subsection{Contributions [remove]}

could be deployed via robotic manipulation
fraction of objects exhibit such simple dynamics.
Deformable objects can be modeled in

described as a multi-body dynamical
system with chaotic or strong nonlinear characteristics as they are largely
indepenent of time and other independent variables. For simplicity we, we adopt
this assumption as it is an important
\emph{prior knowledge} which we will discuss later in this paper.\\

Moreover, our goal is to develop a \emph{data-driven model} that
both accurate and commutationally efficient and enables
\emph{model predictive control} (MPC) for real-time robotics manipulation.

% DLO Dynamics

e.g. learning-based models \cite{nair2017combining}, finite element models,
and latent space models \cite{zhang2021deformable}.

In summary, our contributions are the following.
\begin{itemize}
\item new tasks
\item novel data generation framework
\item Novel RL framework
\end{itemize}
Our source code and dataset are available at .

The remainder of this paper is organized as follows. Relevant related
literature is discussed in Section~\ref{sec:related_work}. Our approach for ...
is presented in Section~\ref{sec:method}. The design and results of our
experiments are demonstrated and explained in
Section~\ref{sec:experimental_evaluation}. In
Section~\ref{sec:conclusion_and_future_work}, the paper is concluded and future
work is discussed.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ------>> DLO research tasks
% ------>> problem statement: in modeling and prediction - chaotic behavior
% ------\--->>> DLO manipulation tasks
% ------\--->>> DLO modeling approaches:---- from mind-map
% ------\--->>> DLO Dynamics and Deformation models
% ------>> recent work and relate to RW
% ------\--->>> General state of the problem: no global system identification on DLOs, high computational costs, inaccuracy
% ------>>
\section{Related Work}
\label{sec:related_work}

% Add subsections as needed
\subsection{[Intro]}

DLO manipulation applications:

Real-time robotic manipulation of deformable linear objects had numerous
applications in medical field, advanced manufacturing, and household robotics,
~\cite{khalil2010dexterous} and
~\cite{sanchez2018robotic}.
Thus far, the research community has develop robust methods for manipulation
of solid objects in real-time. But in reality, many objects are fully or in part
deformable which introduces new levels of complexity to the robotic manipulation
problem. This is especially exacerbated for the real-time robotic manipulation
of deformable objects. New efforts have been made in recent years to solve this
problem; e.g.
folding of cloth {Folding clothes autonomously: A complete pipeline},
surgical suturing {},
knot typing {Motion planning for robotic manipulation of deformable linear objects}
{Tying knot precisely},
and cable manipulation {Cable manipulation with a tactile-reactive gripper}.

for more details on different methods and approaches review \cite{sanchez2018robotic}.
Review by Sanchez et al [ICRA21-002-15]

Real time manipulation of DLOs is a multi-faceted problem and it can be divided
to the following parts, 1) learning the DLO dynamics, 2) representing it in
a computationally efficient manner that would allow for real-time manipulation,

3. and controlling it to reach target configuration.

end to end deep learning approaches:

End-to-end approaches are prone to catastrophic failure and are costly to train
in terms of time and computation.

On DLO prepresentation approaches:

- Learning based representation:
- Model based representation:

\subsection{[summary of related work for DLO manipulation]}

Deformable linear object prediction using locally linear latent dynamics
\cite{zhang2021deformable}

DLO representation: quasi-static and non-quasi-static representations

manipulation of DLOs with quasi-static:
learning based controller:

model based estimator and controllers:

manipulation of DLOs with non-quasi-static representation, \cite{zhang2021robots}

- more feasible for high speed applications
- Movement primitives,a series of open loop control input commands

\subsection{[Koopman Operator and DMD for DLO manipulation]}
\subsection{[piDMD]}

\subsection{[how our method is different from others?]}
In this
paper, we will introduce a new augmented dataset for learning DLO local
dynamics. The dataset is based on a previously available work
\cite{zhang2021deformable} where we added annotation that allows for more
efficient learning of the DLO dynamics. Moreover, unlike \cite{zhang2021deformable}
and \cite{yu2022shape} who used VEA and online-offline Adaptive Control for
configuration estimation, respectively;
we deploy \emph{the Koopman Operator} to
learn the underlying \emph{locally linear dynamics} of the subject DLO.
\cite{zhang2021deformable} is the main paper I am following as for base
example. \cite{yu2022shape}, \cite{zhang2021deformable}, and \cite{zhang2021robots}
are the main papers I am following. Each of those papers have the code
available for them. \cite{yu2022shape} provides the code for a reinforcement
learning data collection setup with Unity and UR5. This is great basis for
my follow up work. \cite{nair2017combining} is the paper I mentioned at the
meeting. This paper is by Levine's group and I think both dataset and learning
method are very bad. Dr. Gans agreed. The rope is not dynamic for the most
part. The test setup does not challenge or interact with object dynamics and
its configuration is mostly determined by contact friction with the table.
Moreover, the learing methods is extremely inefficient because most pixels
in 60K images contain no information regarding object dynamics. My goal is
to learn dynamics with the Koopman Operator only from regions where we observe
a bend on the DLO. Everything else is noise in regards to the dynamics.
I need to read on the Koopman Operator.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update section name as needed
\section{Method}
\label{sec:method}
Various methods have been proposed for modeling or learning state dynamics of
deformable objects
\cite{yu2022shape, zhang2021deformable,zhang2021robots, tang2018framework, khalil2010dexterous}.
However, existing methods suffer from a range of issues that makes them
impractical for deployment in real-time and highly dynamic environment.
These issues are attributed to nonlinear nature of DLO dynamics and high
computational cost associated with real-time perception,
high-dimensional representation and model uncertainty mitigation techniques. \\

With advent of modern GPUs and subsequent advances in data driven methods,
DMD and EDMD were introduced as data analysis methods that extract low-rank
modal structures and dynamics from high dimensional observations
\cite{schmid2010dynamic, williams2015data}. Although DMD is based on
numerical analysis, it is important to note that
\emph{the Koopman Operator} theorizes a nonlinear dynamical system can be
represented as sequence of linear state transitions in a lifted-dimension space.\\

More recently, a modified version of EDMD was deployed to perform real-time
system identification which, yields an explicit representation rather than
\emph{black-box} input-output mapping \cite{bruder2020data}.
For deformable objects in particular, obtaining an accurate and explicit model
of object dynamics in real-time is key for achieving meaningful manipulation
and control.\\

In this work, we aim to take real-time system identification of DLOs one step
further by deploying \emph{Physic Informed DMD} (piDMD) which, allows for
integrating \emph{physical constraints} into machine learing algorithms in
form of \emph{inductive biases} \cite{loiseau2018constrained,baddoo2021physics}.
These constraints are inferred based on
\emph{prior knowledge} about actual physical principles constraining the
object and problem setting at hand.\\

% Add subsections as needed
\subsection{Koopman Operator}
In this section, we briefly review the Koopman operator theory to provide
theoretical basis for our approach. However, we recommend interested readers to
review \cite{budivsic2012applied} for more details.
Suppose the DLO of interest is a dynamical systems defined by
eq(1) and its corresponding discrete time form define by
eq(2) where
\(~F:\mathbb{R}^{n} \rightarrow \mathbb{R}^{n} \) is an unknown state
transition mapping. State transition is represeneted by

\begin{equation} \label{eq:1}
\dot{x}~=~F(x),
\end{equation}
\begin{equation} \label{eq:2}
x*{k+1}~=~F(x*{k}),
\end{equation}

where \(x_k \in M\) describes state of a partially observable dynamical system.
We define an observation co-state and function, \(y_k\) and \(g(x_k)\), as

\begin{equation} \label{eq:3}
y_k~=~g(x_k),
\end{equation}

where \(g~\in~\mathbb{G} : M \rightarrow ~\mathbb{C}\).
\(\mathbb{C} \) describes space of all observations and \(\mathbb{G}\) is
a \(L^2\) function space which, the Koopman operator belongs to.
We define the Koopman operator as

\begin{equation} \label{eq:4}
[\mathcal{K}g](x) = g(F(x)),
\end{equation}

where \(\mathcal{K}:\mathbb{G} \rightarrow \mathbb{G}\). The Koopman operator
maps elements of \(mathbb{G}\) to elements of \(mathbb{G}\) which, meets
the \textbf{isomorphic constraints} for a \emph{lifted-space Koopman operator
representation.} Equation (4) can be rewritten as

\begin{equation} \label{eq:5}
[\mathcal{K}g](x) = g(F(x)) = g(x\_{k+1}),
\end{equation}

where the Koopman operator expresses system state propagation. Since the Koopman
operator theorized a \emph{linear infinite dimensional operator}, we need to
lift the space but it is not practical to lift the space by infinite diminsions.

% Add subsections as needed
\subsection{Koopman Model}
We define an approximate observation function for our Koopman operator as

\begin{equation} \label{eq:6}
y_k = g(x_k) \equiv \Psi(x_k),
\end{equation}

where \(\Psi(x_k)\) is a vector-valued function

\begin{equation} \label{eq:7}
\Psi(x*k) = [\psi*{1}(x),~\psi*{2}(x), ...,~\psi*{N}(x)].
\end{equation}

% Add subsections as needed
\subsection{[follow RamV paper format]}

Define spaces\
Define state vectors\
Define system architecture\
A is triadiagnal matrix \cite{bruder2020data}.\\

\begin{equation} %\label{eq:}
A =
\begin{bmatrix}
\beta*{1}&\gamma*{1}& ~ &~ & ~& \\
\alpha*{2}&\beta*{2}&\gamma*{2} & ~&~&~\\
~& \alpha*{3}&\beta*{3}&\gamma*{3} &~&~\\
~&~& \ddots&\ddots&\ddots &~ \\
~&~&~ & \alpha*{n-1}&\beta*{n-1}&\gamma*{n-1}\\
~&~&~ & ~& \alpha*{n}&\beta\_{n}\\
\end{bmatrix}
\end{equation}

\begin{equation} %\label{eq:3}
argmin || ||2
\end{equation}

They acknowledge some of their solutions are unstable and provide an
\emph{alternative solution to the upper-triangular piDMD problem.} They use
\emph{economy RQ decomposition of X} to write (84) and since \emph{the first
two terms of (84) are independent of \textbf{A} and, by multiplicity of the
Forbenius norm, have a non-negative sum.} On this basis, the
upper-triangular Procrustes is phrased (85) and borrowing a multi-row-wise
optimization computational technique from \emph{Block Discrete Fourier
Transform,} they write (88) as a direct solution for \textbf{A}, given
provided \emph{\textbf{data is rank deficient}}. Most often in real-world
experiments, data collected is rack deficient due to noise and measurement
imperfections. Moreover, they provide (89) as means to compute \textbf{R}
recursively backwards in order incease computational efficacy.
On piDMD \emph{\textbf{BCCB}}, it stands for
\emph{block-continuous-continuous-block} and is a cubic configuration for
performing 3D \emph{fast Fourier transform}. The presented implementtation
does not run and its root cause was not investigated. The implementtation is
equivalent to multiplying data matrix \(\mathbb{X}\) with the Kronecker
product of two \emph{discrete Fourier transform matrices} (DFTMat) with dimension
factors of M and N as input. M and N are the least factors for square
matrices to become the size. This condition is necessary for DFTMat to be
applied to a Tensor. I wonder if using a tensor might be necessary to
correctly meet 3D adjacency constraints of the physical world.\
\emph(UpperTriangular and diagonal) constraints enforce 2D adjacency
but we are only able to run the diagonal. Triangular methods use RQ
decomposition (yields a singular and full-rank matrix for model) and are
thought to be computationally more efficient as
authors claimed~\cite{baddoo2021physics}.\\
I was able to run the algorithm with various \emph{circulant} constraints
which, resulted in poor performance but its surface plot clearly shows a
frequency reconstruction in polar coordinated frame. The implementtation
calls \(fft2()\) routine which, performs \emph{discrete Fourier transform}
on a matrix (2D). Understanding these details is essential for constructing
a viable solution for real-time manipulation and control on DLOs.\\
Furthermore, I continued testing and investigating piDMD and all it can
possibly offer. I plotted reconstructions and model
\emph{performance surfaces} and made a startling realization that piDMD is
only performing system identification task and as implemented, resultant
reconstructions cannot possibly be very accurate. This is related to
highly chaotic nature of DLOs; no matter how accurate and precise the model
is, it will go out of \emph{synch}. Chaotic systems are still nonlinear
systems and they need to be treated \emph{locally in time}. What we are
aiming to achieve is to \emph{model (or linearize)} a
DLO \emph{globally in space}. Thus, there needs to be online observations.\\
I went back to Murphy's paper to implement a Koopman-based controller
where, they use data collected from a
vertical take-off and landing (VTOL) pendulum system \cite{abraham2017model}.
In the paper, they mentioned data collected is a combination of multiple
test runs with different initial conditions. The purpose of this is to
obtain a set of Koopman operators or model that is robust to a range of
initial conditions. Moreover, they use Koopman operator only for system
identification and utilize optimal control with a L2 regularizer.\
Currently, I am working on Koopman operator approximator routine that
takes in number of lifting dimensions and choice of basis functions.
On a side note, we never lifted the space in the current implementation of
DLO code with piDMD but we can as the feature exists.\\

Where each minimization problem (previous eq)\

System identification\\
Estimation Model
Measurement Model

On piDMD \emph{\textbf{BCCB}}, it stands for
\emph{block-continuous-continuous-block} and is a cubic configuration for
performing 3D \emph{fast Fourier transform}. The presented implementtation
does not run and its root cause was not investigated. The implementtation is
equivalent to multiplying data matrix \(\mathbb{X}\) with the Kronecker
product of two \emph{discrete Fourier transform matrices} (DFTMat) with dimension
factors of M and N as input. M and N are the least factors for square
matrices to become the size. This condition is necessary for DFTMat to be
applied to a Tensor. I wonder if using a tensor might be necessary to
correctly meet 3D adjacency constraints of the physical world.\
\emph(UpperTriangular and diagonal) constraints enforce 2D adjacency
but we are only able to run the diagonal. Triangular methods use RQ
decomposition (yields a singular and full-rank matrix for model) and are
thought to be computationally more efficient as
authors claimed~\cite{baddoo2021physics}.\\
I was able to run the algorithm with various \emph{circulant} constraints
which, resulted in poor performance but its surface plot clearly shows a
frequency reconstruction in polar coordinated frame. The implementtation
calls \(fft2()\) routine which, performs \emph{discrete Fourier transform}
on a matrix (2D). Understanding these details is essential for constructing
a viable solution for real-time manipulation and control on DLOs.\\
Furthermore, I continued testing and investigating piDMD and all it can
possibly offer. I plotted reconstructions and model
\emph{performance surfaces} and made a startling realization that piDMD is
only performing system identification task and as implemented, resultant
reconstructions cannot possibly be very accurate. This is related to
highly chaotic nature of DLOs; no matter how accurate and precise the model
is, it will go out of \emph{synch}. Chaotic systems are still nonlinear
systems and they need to be treated \emph{locally in time}. What we are
aiming to achieve is to \emph{model (or linearize)} a
DLO \emph{globally in space}. Thus, there needs to be online observations.\\
I went back to Murphy's paper to implement a Koopman-based controller
where, they use data collected from a
vertical take-off and landing (VTOL) pendulum system \cite{abraham2017model}.
In the paper, they mentioned data collected is a combination of multiple
test runs with different initial conditions. The purpose of this is to
obtain a set of Koopman operators or model that is robust to a range of
initial conditions. Moreover, they use Koopman operator only for system
identification and utilize optimal control with a L2 regularizer.\
Currently, I am working on Koopman operator approximator routine that
takes in number of lifting dimensions and choice of basis functions.
On a side note, we never lifted the space in the current implementation of
DLO code with piDMD but we can as the feature exists.\\

% Add section/subsection for dataset

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Experimental Evaluation}
\label{sec:experimental_evaluation}

Setup

Experiments

System Identification Experiments

Manipulation Task Experiments

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Conclusion and Future Work}
\label{sec:conclusion_and_future_work}

Observations
What makes sense
What doesnt make sense
Future Work

%\section\*{Acknowledgments}

\bibliographystyle{IEEEtran}
\bibliography{IEEEabrv,deformable_linear_objects_dataset_and_evaluation}
\end{document}
