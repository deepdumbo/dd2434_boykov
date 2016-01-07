function [ G ] = buildImgGraph( img, fgseeds, bgseeds, lambda )

 % Reshape image and masks
[h, w, c] = size(img);
Simg = reshape(img, h*w, c);
Sfgseeds = reshape(fgseeds, h*w, 1);
Sbgseeds = reshape(bgseeds, h*w, 1);
nodeId = 1:h*w;

% Compute histograms on seeded pixels
[fgHist, binLocations] = imhist(Simg(Sfgseeds == 255,:));
[bgHist, ~] = imhist(Simg(Sbgseeds == 255,:));

% Compute the distribution probability Pr(Ip|O) and Pr(Ip|B)
fgHist = fgHist ./ sum(fgHist);
bgHist = bgHist ./ sum(bgHist);

% Example 
% Rp_fg for the pixel in (1,1)
%Rp_fg = fgHist(binLocations == img(1,1,:));

% Compute the graph edges from the image size
[ edges, sinkId, sourceId ] = edgeList( h, w );

% Compute the edges to the sink and the source
sinkEdges = [sinkId*ones(1,h*w); 1:h*w];
sourceEdges = [sourceId*ones(1,h*w); 1:h*w];

% Compute Bpq weights
weights = rbf(single(Simg(edges(1,:))), single(Simg(edges(2,:))));

% Compute sink weights
K = sum(weights); % TODO

sinkWeights = zeros(1, h*w);
sinkWeights(Sfgseeds == 255) = 0;
sinkWeights(Sbgseeds == 255) = K;
sinkWeights((Sfgseeds == 0) .* (Sbgseeds == 0) == 1) = lambda * fgHist(1+Simg((Sfgseeds == 0) .* (Sbgseeds == 0) == 1));

G = graph(  [edges(1,:) sinkEdges(1,:) sourceEdges(1,:)], ...
            [edges(2,:) sinkEdges(2,:) sourceEdges(2,:)], ...
            [weights sinkWeights sourceWeights]);
        
plot(G,'Layout','layered')

end
