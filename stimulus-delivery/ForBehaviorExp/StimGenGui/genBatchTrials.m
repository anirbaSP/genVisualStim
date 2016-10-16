function genBatchTrials

stimTable;

n_table = length(tablec);
for i = 1:n_table
    table = tablec{i};
    stimType = stimType{i};
    trailsc{i} = trialStruct(stimType, table);
end

% to do: mix trails together



