function found_row = findme(lookforme, headers)
% Finds and returns a row containing word lookforme from matrix. If not
% found, return empty string. If multiple found, first is returned

row_to_check = headers;
helper = 0;

while (helper == 0) && ~(isempty(row_to_check))
	if ~(max(regexpi(row_to_check(1,:), lookforme)) == 0)
		found_row = row_to_check(1,:);
		helper = 1;
	else
		row_to_check=row_to_check(2:size(row_to_check),:);
		found_row=' ';
	end
end
