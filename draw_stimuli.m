lum = 0;
ppd = 35;

gb = circgabor(1, 0, 0.5, 0.5, ppd, [1 0 0]);
img = gb(:,:,2:4).*gb(:,:,1) + lum*ones(size(gb,[1 2])).*(1-gb(:,:,1));
figure; imshow(img);

gb = circgabor(1, 15, 0.5, 0.5, ppd, [1 0 0]);
img = gb(:,:,2:4).*gb(:,:,1) + lum*ones(size(gb,[1 2])).*(1-gb(:,:,1));
figure; imshow(img);

gb = circgabor(1, 0, 0.5, 0.5, ppd, [0 1 0]);
img = gb(:,:,2:4).*gb(:,:,1) + lum*ones(size(gb,[1 2])).*(1-gb(:,:,1));
figure; imshow(img);

gb = circgabor(1, 15, 0.5, 0.5, ppd, [0 1 0]);
img = gb(:,:,2:4).*gb(:,:,1) + lum*ones(size(gb,[1 2])).*(1-gb(:,:,1));
figure; imshow(img);