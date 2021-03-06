library(readr)
library(tidyr)
library(dplyr)
library(stringr)
library(ggplot2)

score_wide <- read_csv("score.csv")
score_long <- gather(score_wide, "class", "score", 3:7)
score_long <- score_long %>% mutate(id2=as.factor(str_replace(id, "20130521", "")))

score_long2 <- score_long %>% filter(str_detect(class, "e"))
gb <- ggplot(score_long2, aes(class, score))
gb <- gb + geom_boxplot(aes(color=class))
ggsave("exp_boxplog.png", gb)

gl <- ggplot(score_long2, aes(class, score, group=id2))
gl <- gl + geom_point()
gl <- gl + geom_line(aes(color=id2))
ggsave("id_lineplot.png", gl)

lm_eqn <- function(df) {
  m <- lm(final ~ exp, df)
  eq <- substitute(italic(y) == a + b %.% italic(x) *","* ~~italic(r)~"="~r1 *","* ~~italic(R)^2~"="~r2, 
                   list(a = format(coef(m)[1], digits=2), 
                        b = format(coef(m)[2], digits=2), 
                        r1 = format(sqrt(summary(m)$r.squared), digits=3),
                        r2 = format(summary(m)$r.squared, digits=3)))
  as.character(as.expression(eq))
}

score_wide2 <- score_wide %>% group_by(id,name,final) %>% summarise(exp=mean(c(e6,e7,e8,e9))) 
#score_exp <- score_long %>% filter(str_detect(class, "e")) %>% group_by(id,name) %>% summarise(exp=mean(score))
#score_final <- score_long %>% filter(str_detect(class, "final")) %>% group_by(id,name) %>% summarise(final=score)
#score_wide2 <- inner_join(score_exp, score_final)
gr <- ggplot(score_wide2, aes(exp, final))
gr <- gr + geom_point()
gr <- gr + geom_smooth(method="lm", color="red", formula=y~x)
gr <- gr + geom_text(x=82, y=100, label=lm_eqn(score_wide2), parse=TRUE, size=5, color="blue")
ggsave("correlation_plot.png", gr)

id1 <- score_wide2[which.min(score_wide2$final),]$id
score_wide3 <- score_wide2 %>% filter(id!=id1)
#score_wide3 <- score_wide2 %>% filter(id!="2013052125")
gr2 <- ggplot(score_wide3, aes(exp, final))
gr2 <- gr2 + geom_point()
gr2 <- gr2 + geom_smooth(method="lm", color="red", formula=y~x)
gr2 <- gr2 + geom_text(x=82, y=100, label=lm_eqn(score_wide3), parse=TRUE, size=5, color="blue")
ggsave("correlation_plot_correct.png", gr2)
