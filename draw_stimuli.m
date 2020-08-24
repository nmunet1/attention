lum = 0; % background luminance (0=black, 1=white)
ppd = 35; % pixels per degree

colors = [1 1 1; 0 1 0; 1 0 0];
angles = [0 15];

for c = colors'
    for theta = angles
        gb = circgabor(2, theta, 0.85, 1, ppd, c);
        img = gb(:,:,2:4).*gb(:,:,1) + lum*ones(size(gb,[1 2])).*(1-gb(:,:,1));
        figure; imshow(img);
    end
end