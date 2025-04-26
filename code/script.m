% Network Simulation Script
% Simulates different backoff strategies for collision avoidance in a network

% Read and validate input parameters
[networkParams, isValid] = readNetworkParameters('input_network.txt');
if ~isValid
    error('Invalid input parameters');
end

% Extract parameters
numNodes = networkParams(1);
packetSizeBits = networkParams(2) * 8;
simulationTime = networkParams(3) * 10^-3;
backoffStrategy = networkParams(4);

% Network constants
NETWORK_CONSTANTS = struct(...
    'dataRate', 6 * 10^6, ... % 6 Mbps
    'timeSlotSize', 9 * 10^-6, ... % 9 us
    'minContentionWindow', 15 ...
);

% Calculate packet transmission time
packetTransmissionTime = packetSizeBits / NETWORK_CONSTANTS.dataRate;

% Run simulation based on selected strategy
[networkUtilization, stats] = runSimulation(numNodes, packetTransmissionTime, ...
    simulationTime, backoffStrategy, NETWORK_CONSTANTS);

% Display results
displayResults(numNodes, networkParams(2), simulationTime, backoffStrategy, networkUtilization);

% Function to read and validate network parameters
function [params, isValid] = readNetworkParameters(filename)
    try
        fileID = fopen(filename, 'r');
        formatSpec = '%f';
        params = fscanf(fileID, formatSpec);
        fclose(fileID);
        
        % Validate parameters
        isValid = length(params) >= 4 && ...
                 params(1) > 0 && ... % numNodes
                 params(2) > 0 && ... % packetSize
                 params(3) > 0 && ... % simulationTime
                 params(4) >= 1 && params(4) <= 5; % backoffStrategy
    catch
        params = [];
        isValid = false;
    end
end

% Function to run the network simulation
function [utilization, stats] = runSimulation(numNodes, packetTransmissionTime, ...
    simulationTime, backoffStrategy, constants)
    
    % Initialize simulation variables
    totalSimTime = 0;
    collisionCount = 0;
    successfulTransmissionTime = 0;
    collisionIndexCounter = 1;
    simulationIterations = 0;
    contentionWindow = constants.minContentionWindow;
    hasCollision = 0;
    
    % Initialize backoff counters for all nodes
    backoffCounters = (randi([0, constants.minContentionWindow], numNodes, 1)) * 10^-6;
    
    % Main simulation loop
    while totalSimTime < simulationTime
        % Find node with minimum backoff
        [minBackoff, minBackoffNodeIndex] = min(backoffCounters);
        simulationIterations = simulationIterations + 1;
        
        % Check for collisions
        [collisionCount, collisionNodes] = checkCollisions(backoffCounters, minBackoff, ...
            collisionIndexCounter);
        hasCollision = collisionCount > 1;
        
        % Handle transmission based on collision status
        if ~hasCollision
            [successfulTransmissionTime, contentionWindow, backoffCounters] = ...
                handleSuccessfulTransmission(successfulTransmissionTime, ...
                packetTransmissionTime, contentionWindow, backoffCounters, ...
                minBackoffNodeIndex, backoffStrategy);
        else
            [contentionWindow, backoffCounters] = handleCollision(contentionWindow, ...
                backoffCounters, minBackoff, numNodes, backoffStrategy);
        end
        
        % Update simulation time and backoff counters
        totalSimTime = totalSimTime + packetTransmissionTime;
        backoffCounters = updateBackoffCounters(backoffCounters, collisionNodes, ...
            constants.timeSlotSize, numNodes);
        
        % Reset collision tracking
        collisionCount = 0;
        hasCollision = 0;
    end
    
    % Calculate final statistics
    utilization = successfulTransmissionTime / totalSimTime;
    stats = struct('iterations', simulationIterations, ...
                  'totalTime', totalSimTime, ...
                  'successfulTime', successfulTransmissionTime);
end

% Function to check for collisions
function [collisionCount, collisionNodes] = checkCollisions(backoffCounters, ...
    minBackoff, collisionIndexCounter)
    collisionCount = 0;
    collisionNodes = zeros(1, length(backoffCounters));  % Pre-allocate for worst case
    
    for nodeIndex = 1:length(backoffCounters)
        if (minBackoff == backoffCounters(nodeIndex))
            collisionCount = collisionCount + 1;
            collisionNodes(collisionIndexCounter) = nodeIndex;
            collisionIndexCounter = collisionIndexCounter + 1;
        end
    end
end

% Function to handle successful transmission
function [successfulTransmissionTime, contentionWindow, backoffCounters] = ...
    handleSuccessfulTransmission(successfulTransmissionTime, packetTransmissionTime, ...
    contentionWindow, backoffCounters, minBackoffNodeIndex, backoffStrategy)
    
    successfulTransmissionTime = successfulTransmissionTime + packetTransmissionTime;
    
    % Update contention window based on strategy
    switch backoffStrategy
        case 1
            contentionWindow = constants.minContentionWindow;
        case 2
            contentionWindow = round(contentionWindow, 2);
        case 3
            contentionWindow = round(contentionWindow, 2);
        case 4
            contentionWindow = contentionWindow - 2;
            if contentionWindow < 1
                contentionWindow = 2;
            end
        case 5
            contentionWindow = contentionWindow - 2;
            if contentionWindow < 1
                contentionWindow = 2;
            end
    end
    
    % Update backoff counter for transmitting node
    backoffCounters(minBackoffNodeIndex) = (randi([0, contentionWindow], 1, 1)) * 10^-6;
end

% Function to handle collision
function [contentionWindow, backoffCounters] = handleCollision(contentionWindow, ...
    backoffCounters, minBackoff, numNodes, backoffStrategy)
    
    % Update contention window based on strategy
    switch backoffStrategy
        case {1, 3, 5}
            contentionWindow = contentionWindow * 2;
        case {2, 4}
            contentionWindow = contentionWindow + 2;
    end
    
    % Update backoff counters for colliding nodes
    for nodeIndex = 1:numNodes
        if (minBackoff == backoffCounters(nodeIndex))
            backoffCounters(nodeIndex) = (randi([0, contentionWindow], 1, 1)) * 10^-6;
        end
    end
end

% Function to update backoff counters
function backoffCounters = updateBackoffCounters(backoffCounters, collisionNodes, ...
    timeSlotSize, numNodes)
    for nodeIndex = 1:numNodes
        for collisionNodeIndex = 1:length(collisionNodes)
            if(nodeIndex ~= collisionNodes(collisionNodeIndex))
                backoffCounters(nodeIndex) = backoffCounters(nodeIndex) - timeSlotSize;
            end
        end
    end
end

% Function to display results
function displayResults(numNodes, packetSize, simulationTime, backoffStrategy, utilization)
    fprintf('Number of Nodes: %d ; Packet Size: %d ; Simulation Time(s): %d ; Backoff Strategy: %d \n', ...
        numNodes, packetSize, simulationTime, backoffStrategy);
    fprintf('Network Utilization: %.4f\n', utilization);
end
