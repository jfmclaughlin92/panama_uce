makeSNP_clines <- function(dataset){
  allSNPs <- dataset[,4:ncol(dataset)]
  SNPs <- allSNPs[,seq(1,ncol(allSNPs), by = 2)] # need to isolate SNPs only
  bird <- list()
  for(SNP in 1:ncol(SNPs))
  {
    print(SNP)
    print(ncol(SNPs))
    SNPname <- paste("SNP",SNP,sep="")
    
    obsData <- paste("obsData",SNPname, sep=".") 
    
    obsData <- hzar.doMolecularData1DPops(dataset$KM, SNPs[,SNP], dataset$Alleles, row.names(dataset))
    
    bird$SNPname$obs <- list()
    bird$SNPname$models <- list()
    bird$SNPname$fitRs <- list()
    bird$SNPname$runs <- list()
    bird$SNPname$analysis <- list()
    
    bird$SNPname$obs <-  obsData
    
    bird_modelLoad <- function(scaling,tails,id=paste(scaling,tails,sep=".")) bird$SNPname$models[[id]] <<- hzar.makeCline1DFreq(bird$SNPname$obs,scaling,tails)
    bird_modelLoad("fixed","none","modelI");
    bird_modelLoad("free","none","modelII");
    bird_modelLoad("free","both","modelIII");
    bird$SNPname$models <- sapply(bird$SNPname$models,hzar.model.addBoxReq, -30, 900, simplify = FALSE)
    bird$SNPname$fitRs$init <- sapply(bird$SNPname$models, hzar.first.fitRequest.old.ML,obsData=bird$SNPname$obs, verbose=FALSE, simplify = FALSE)
    
    chainLength <- 1e5
    mainSeed <- list(A=c(596,528,124,978,544,99),B=c(528,124,978,544,99,596),C=c(124,978,544,99,596,528))
    bird$SNPname$fitRs$init$modelI$mcmcParam$chainLength <- chainLength;
    bird$SNPname$fitRs$init$modelI$mcmcParam$burnin <- chainLength %% 10;
    bird$SNPname$fitRs$init$modelI$mcmcParam$seed[[1]] <- mainSeed$A;
    bird$SNPname$fitRs$init$modelII$mcmcParam$chainLength <- chainLength;
    bird$SNPname$fitRs$init$modelII$mcmcParam$burnin <- chainLength %% 10;
    bird$SNPname$fitRs$init$modelII$mcmcParam$seed[[1]] <- mainSeed$B;
    bird$SNPname$fitRs$init$modelIII$mcmcParam$chainLength <- chainLength;
    bird$SNPname$fitRs$init$modelIII$mcmcParam$burnin <- chainLength %% 10;
    bird$SNPname$fitRs$init$modelIII$mcmcParam$seed[[1]] <- mainSeed$C;
    
    bird$SNPname$runs$init <- list()
    bird$SNPname$runs$init$modelI <- hzar.doFit(bird$SNPname$fitRs$init$modelI)
    bird$SNPname$runs$init$modelII <- hzar.doFit(bird$SNPname$fitRs$init$modelII)
    bird$SNPname$runs$init$modelIII <- hzar.doFit(bird$SNPname$fitRs$init$modelIII)
    bird$SNPname$fitRs$chains <- lapply(bird$SNPname$runs$init,hzar.next.fitRequest)
    bird$SNPname$fitRs$chains <- hzar.multiFitRequest(bird$SNPname$fitRs$chains,each=3,baseSeed= NULL)
    bird$SNPname$runs$chains <- hzar.doChain.multi(bird$SNPname$fitRs$chains,doPar=TRUE,inOrder=FALSE, count=3)
    bird$SNPname$runs$chains <- hzar.doChain.multi(bird$SNPname$fitRs$chains,doPar=TRUE,inOrder=FALSE, count=3)
    
    bird$SNPname$analysis$initDGs$modelI <- hzar.dataGroup.add(bird$SNPname$runs$init$modelI)
    bird$SNPname$analysis$initDGs$modelII <- hzar.dataGroup.add(bird$SNPname$runs$init$modelII)
    bird$SNPname$analysis$initDGs$modelIII <- hzar.dataGroup.add(bird$SNPname$runs$init$modelIII)
    bird$SNPname$analysis$oDG <- hzar.make.obsDataGroup(bird$SNPname$analysis$initDGs)
    bird$SNPname$analysis$oDG <- hzar.copyModelLabels(bird$SNPname$analysis$initDGs, bird$SNPname$analysis$oDG)
    bird$SNPname$analysis$oDG <- hzar.make.obsDataGroup(lapply(bird$SNPname$runs$chains, hzar.dataGroup.add),bird$SNPname$analysis$oDG);
    hzar.plot.cline(bird$SNPname$analysis$oDG)
    print(bird$SNPname$analysis$AICcTable <- hzar.AIC.hzar.obsDataGroup(bird$SNPname$analysis$oDG));
    print(bird$SNPname$analysis$model.name <- rownames(bird$SNPname$analysis$AICcTable)[[which.min(bird$SNPname$analysis$AICcTable$AIC)]])
    bird$SNPname$analysis$model.selected <- bird$SNPname$analysis$oDG$data.groups[[bird$SNPname$analysis$model.name]]
    print(hzar.get.ML.cline(bird$SNPname$analysis$model.selected))
    hzar.plot.cline(bird$SNPname$analysis$model.selected);
    bird.SNPname.analysis <- bird$SNPname$analysis
    filename <- paste(bird.SNPname.analysis, "RData", sep=".")
    save(bird.SNPname.analysis, file="bird_SNPname.RData")
    
    print(SNPname)
    next
  }
  
}

