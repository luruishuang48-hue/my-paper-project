#!/usr/bin/env Rscript
# 图1：事件时间累计异常收益剖面（读 paper_numbers.csv，输出 Tex_new/figures/）
args <- commandArgs(trailingOnly = FALSE)
sd <- dirname(sub("--file=", "", args[grep("--file=", args)]))
root <- normalizePath(file.path(sd, "..", ".."))
pn <- read.csv(file.path(root, "Analysis/reports/paper_numbers.csv"), stringsAsFactors = FALSE)
wins <- c("car_mm_spy_pre_m10_m2","car_mm_spy_0_0","car_mm_spy_0_1","car_mm_spy_0_2",
          "car_mm_spy_0_3","car_mm_spy_0_5","car_mm_spy_0_10","car_mm_spy_0_15","car_mm_spy_0_20")
xs <- c(-6, 0, 1, 2, 3, 5, 10, 15, 20)   # 前窗画在 -6（[-10,-2] 中点）
labs <- c("pre","0","1","2","3","5","10","15","20")
get <- function(blk, term) sapply(wins, function(w) pn$coef[pn$block==blk & pn$y==w & pn$term==term])
gse <- function(blk, term) sapply(wins, function(w) pn$se[pn$block==blk & pn$y==w & pn$term==term])
pdf(file.path(root, "Tex_new/figures/fig1_car_profile.pdf"), width = 10, height = 4.6)
par(mfrow = c(1, 2), mar = c(4, 4, 2.2, 0.8), mgp = c(2.4, 0.7, 0))
panel <- function(blk, title) {
  hw <- get(blk, "rel_upstream_hardware") * 100
  se <- gse(blk, "rel_upstream_hardware") * 100
  cp <- get(blk, "rel_competitor") * 100
  dp <- get(blk, "rel_downstream_deployer") * 100
  ylim <- range(c(hw + 1.96*se, hw - 1.96*se, cp, dp, 0))
  plot(xs, hw, type = "n", ylim = ylim, xlab = "Trading days relative to release",
       ylab = "CAR coefficient (pp)", main = title, xaxt = "n", cex.main = 1)
  axis(1, at = xs, labels = labs)
  polygon(c(xs, rev(xs)), c(hw + 1.96*se, rev(hw - 1.96*se)), col = "#d8d8d8", border = NA)
  abline(h = 0, lty = 3); abline(v = -3, lty = 3, col = "grey55")
  lines(xs, hw, lwd = 2.2);            points(xs, hw, pch = 16, cex = .85)
  lines(xs, cp, lwd = 1.6, lty = 2);   points(xs, cp, pch = 17, cex = .8)
  lines(xs, dp, lwd = 1.6, lty = 4);   points(xs, dp, pch = 15, cex = .8)
  legend("topleft", c("Upstream hardware (95% CI)","Competitor","Downstream deployer"),
         lty = c(1,2,4), pch = c(16,17,15), lwd = c(2.2,1.6,1.6), bty = "n", cex = .82)
}
panel("prof_full", "Full sample (124 events)")
panel("prof_2526", "2025-2026 (68 events)")
dev.off()
cat("fig1 written\n")
