function gb  = circgabor(sigma, theta, lambda, contrast, pixelsperdegree, ring_color)

nstd = 3; % standard devs w/in boundary radius
rmax = nstd*sigma; % radius/half-width of box, in deg

r_ring = rmax-0.1; % ring radius, in deg
sigma_ring = 0.025; % ring gaussian sigma, in deg

r = (-rmax*pixelsperdegree:rmax*pixelsperdegree)/pixelsperdegree;
[x,y] = meshgrid(r,r);

% layer 1: gabor
l1 = 0.5*(contrast*(cosd((x*cosd(theta) + y*sind(theta))*360/lambda)+1) + (1-contrast)); % cosine grating
alpha1 = exp(-0.5*(x.^2 + y.^2)/sigma.^2); % Gaussian transparency

if ~isempty(ring_color)
    % layer 2: ring
    alpha2 = exp(-0.5*(sqrt(x.^2 + y.^2) - r_ring).^2/sigma_ring.^2);
    l2 = repmat(reshape(ring_color, [1 1 3]), [size(x) 1]);
    
    % layers 1 + 2 combined
    alpha12 = alpha2 + alpha1 - alpha1.*alpha2;
    l12 = (alpha1.*(1-alpha2)./alpha12).*l1 + (alpha2./alpha12).*l2;
    
    gb = cat(3, alpha12, l12);
else
    gb = cat(3, alpha1, l1, l1, l1);
end

end