function trajPlot(j) % Nice plot of trajectories
  yticks([-pi/4,0,pi/4]); yticklabels([{'$-\pi/4$'},{'0'},{'$\pi/4$'}])
  set(gca,'TickLabelInterpreter','Latex','FontSize',20);grid on
  ylim([-1,1])
  ylabel(j,'Interpreter','latex','FontSize',20)
end
