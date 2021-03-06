function Dictionary_Learning_KL_method()
clear all;
tic
randn('state',1);
rand('state',1);
%setup_DL
%Handle random seed
defaultStream = RandStream.getGlobalStream; %% the function for this code 
if 1
    savedState = defaultStream.State; 
    save random_state.mat savedState;
else
    load random_state.mat %#ok<UNRCH>
end
defaultStream.State = savedState; %


SNRrange = [10:5:50];
SparseK = [0.3]; % sparsity ratio per column
SimLen = 1;%

size_coeff = [1];
Threshold = 1e-3; % 

%Flags to test BiG-AMP variants
optIn.tryBigampEM = 1;

%Flags to turn on comparison algorithms
optIn.tryKsvd = 0;
optIn.tryErspud = 0;
optIn.trySpams = 0;
optIn.maxTrials = 1; 

InpNoiseVar = 1.3641e+00;
InpNoiseMean = 7.0268e-05;
ScalarMean = 7.1537e-01;
ScalarVar = 3.8212e-04; 
errorA_hist = zeros(length(size_coeff),length(SparseK));
errorX_hist = zeros(length(size_coeff),length(SparseK));
Avar_estimate_set = [];
Xvar_estimate_set = [];
Avar_true_set = [];
Xvar_true_set = [];
Nrrange = [200];
for iSZ = 1:length(size_coeff)
    for iK = 1:length(SparseK)
        for iN = 1:length(Nrrange)
            Ntrange = [20]*size_coeff(iSZ); % transmit antenna
            Nrrange = [200]*size_coeff(iSZ);%ceil(5.*Nrange.*log(Nrange));% [100]; % receive antenna
            optIn.N = Ntrange(1); %
            optIn.M = 100*size_coeff(iSZ);%optIn.N; % coherence time
            optIn.K = round(SparseK(iK)*optIn.N);
            Llower = 180;
            Lupper = 0;
            Nr = Nrrange(iN);


            optIn.L = Nr;


            AMSE = zeros(2,length(SNRrange)); % average over channel samples
            XMSE = zeros(2,length(SNRrange)); % average over channel samples
            Rate = zeros(2,length(SNRrange));
            NoiseVar = zeros(optIn.N,optIn.N,length(SNRrange));

            Noise = zeros(optIn.M,optIn.N,SimLen*optIn.maxTrials,length(SNRrange));
            Scalar = zeros(optIn.N,SimLen*optIn.maxTrials,length(SNRrange));
            ErrorCount = 0;
            errorA_hist1 = [];
            errorX_hist1 = [];
            for sim = 1:SimLen %?
                tAMSE = zeros(2,length(SNRrange));
                tXMSE = zeros(2,length(SNRrange));
                tRate = zeros(2,length(SNRrange));
                tNoiseVar = zeros(optIn.N,optIn.N,length(SNRrange));

                for iS = 1:length(SNRrange)
                    %Specify maximum allowed trials
                    %optIn.maxTrials = 1;
                    %SNR
                    optIn.SNR = SNRrange(iS); % un-use in this program
                    %Specify coding mode (0 for OMP, 1 for TST)
                    %The specified function is used to compute a coding error for the
                    %resulting dictionary for each algorithm. TST may be significantly
                    %slower.
                    optIn.useTST = 0;

                    %Precondition option (enable to use a preconditioner for EM-BiG-AMP)
                    optIn.precondition = 0;

                    optIn.nit = 100; %limit iterations

    %                 optIn.NoiseVar = InpNoiseVar(iS);
    %                 optIn.NoiseMean = InpNoiseMean(iS);
    %                 optIn.ScalarVar = ScalarVar(iS);
    %                 optIn.ScalarMean = ScalarMean(iS);

                    optIn.uniformVariance = 0; % 1 for uniform variance; 0 for general case

                    results = DLCommun_LMMSE_ref(optIn); % subspace estimation
                    Avar_estimate_set = [Avar_estimate_set, results{1, 1}.optIn.Avar_estimate];
                    Xvar_estimate_set = [Xvar_estimate_set, results{1, 1}.optIn.Xvar_estimate];
                    Avar_true_set = [Avar_true_set, results{1, 1}.optIn.Avar_true];
                    Xvar_true_set = [Xvar_true_set, results{1, 1}.optIn.Xvar_true];
                    errorA_hist1 = [errorA_hist1,results{1,1}.Aerror];
                    errorX_hist1 = [errorX_hist1,results{1,1}.Xerror];
                    Aerror = min(errorA_hist1);
                    Xerror = min(errorX_hist1);
                    errorA_hist(iS,iK) = Aerror;
                    errorX_hist(iS,iK) = Xerror;
                end
            end

        end
    end
end
plot(SNRrange,errorA_hist)
%save('D:/AMP_Neural/_result/New_KL_errA_DL_change_SNR2.mat','errorA_hist');
%save('D:/AMP_Neural/_result/New_KL_errX_DL_change_SNR2.mat','errorX_hist');
%save('D:/AMP_Neural/_result/Big_AMP_errA_DL_change_sparsity_and_NKratio.mat','errorA_hist');
%save('D:/AMP_Neural/_result/Big_AMP_errX_DL_change_sparsity_and_NKratio.mat','errorX_hist');
%save('D:/AMP_Neural/_result/DL_Low_BIG_errA_change_size_sparsity.mat','errorA_hist');
%save('D:/AMP_Neural/_result/DL_Low_BIG_errX_change_size_sparsity.mat','errorX_hist');
%save('C:\Users\DELL\Desktop\Paper use code\_result\Avar_true_set','Avar_true_set');
%save('C:\Users\DELL\Desktop\Paper use code\_result\Xvar_true_set','Xvar_true_set');
%save('C:\Users\DELL\Desktop\Paper use code\_result\Avar_estimate_set','Avar_estimate_set');
%save('C:\Users\DELL\Desktop\Paper use code\_result\Xvar_estimate_set','Xvar_estimate_set');
end