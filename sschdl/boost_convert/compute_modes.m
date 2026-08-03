function vs = compute_modes(x, u, t)

  tmp1 = (((-1.0) .* x(1)) + ((-1e-06) .* x(3)) + ((-1.0) .* x(4)) + (5.0));
  tmp2 = u(1);

  v1 = (tmp1 > (0.7));
  v2 = (tmp2 > (2.0));

  vs = [v1 v2];

end
