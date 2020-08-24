function gb  = circgabor(sigma, theta, freq, contrast, pixelsperdegree, color)

nstd = 3; % standard devs w/in boundary radius
rmax = nstd*sigma; % radius/half-width of box, in deg

r = (-rmax*pixelsperdegree:rmax*pixelsperdegree)/pixelsperdegree;
[x,y] = meshgrid(r,r);

z = 0.5*(contrast*(cosd((x*cosd(theta) + y*sind(theta))*360*freq)+1) + (1-contrast)); % cosine grating
alpha = exp(-0.5*(x.^2 + y.^2)/sigma.^2); % Gaussian transparency

gb = cat(3, alpha, z*color(1), z*color(2), z*color(3));

end