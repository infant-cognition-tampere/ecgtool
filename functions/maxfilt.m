function out = maxfilt(in,a)
% Some function of probably HR-calculation that was not part of the
% Ecgtool-development but the algorithm to computate heartrates.

le = length(in);

as = (a-1)/2;

out=zeros(size(in));

for j = 1:le,
   if j <= as
      out(j) = max(in(1:j+as));
   elseif j > le-as
      out(j) = max(in(j-as:le));
   else
      out(j) = max(in(j-as:j+as));
   end
end