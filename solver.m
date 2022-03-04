% 数独求解程序

% 由于数独问题的规则“行、列、块”每个数字只能出现一次可以翻译为一个规划问题(还有每格只能取一个值的约束）
% matlab具有整数型线性规划求解函数，由于是np难问题，经查找资料其使用的是启发式算法
% 发现了一个奇妙的现象，第一次运行会较慢，之后都会较快，无论是不是相同的数独

% 官网Documentation
% x = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub) defines a set of lower and upper bounds on the design variables, x, 
% so that the solution is always in the range lb ≤ x ≤ ub. Set Aeq = [] and beq = [] if no equalities exist.

tic
flag = 0; % 使用fixed设置为0，使用original设置为1
% 图14
fixed = [1 3 7
1 5 2
2 4 3
2 7 4
3 1 9
3 5 1
3 8 2
4 2 1
4 6 2
5 1 7
5 3 8
5 7 3
5 9 9
6 4 4
6 8 7
7 2 5
7 5 7
7 9 8
8 3 3
8 6 6
9 5 3
9 7 1];
% 图13
original = [0 0 7 0 0 0 2 0 0
0 0 0 0 3 0 0 0 0
2 0 0 6 9 5 0 0 7
0 0 5 0 0 0 7 0 0
0 9 4 0 8 0 5 2 0
0 0 8 0 0 0 3 0 0 
4 0 0 9 1 7 0 0 6
0 0 0 0 5 0 0 0 0
0 0 3 0 0 0 1 0 0];

%% 目标函数
N = 9 * 9 * 9;
f = zeros(N, 1);

%% 需要求解的自变量的数量
intcon = 1:N;

%% 约束方程
numOfConstraint = 9 * 9 + 3 * 9 * 9; % 每格只能取一个值 + 每行/列/块每个数字只能出现一次
Aeq = zeros(numOfConstraint, N);
Constraint = 1;
% 每格只能取一个值与每行/列每个数字只能出现一次
for m = 1:9
    for n = 1:9
        % 每格
        layer = 0:81:8 * 81;
        location = m + (n - 1) * 9;
        Aeq(Constraint, location + layer) = 1; 
        Constraint = Constraint + 1;
        % 每行
        y = 1:9;      
        location = (n - 1) * 81 + m;
        Aeq(Constraint, location + (y - 1) * 9) = 1; 
        Constraint = Constraint + 1;
        % 每列
        x = 1:9;
        location = (n - 1) * 81 + (m - 1) * 9;
        Aeq(Constraint, location + x) = 1; 
        Constraint = Constraint + 1;
    end
end
% 每格每个数字只能出现一次 
for x = 1:3
    for y = 1:3
        for z = 1:9
            location = (z - 1) * 81 + (x - 1) * 3 + (y - 1) * 3 * 9;
            shift = [1 2 3 10 11 12 19 20 21];
            Aeq(Constraint, location + shift) = 1;
            Constraint = Constraint + 1;
        end
    end
end
beq = ones(numOfConstraint, 1);


%% 上下限
if flag == 0 % 使用fixed
    lb = zeros(N, 1);
    for n = 1:size(fixed,1)
        lb(fixed(n, 1) + 9 * (fixed(n, 2) - 1) + 81 * (fixed(n, 3) - 1)) = 1;
    end
else % 使用original
    original01 = zeros(9, 9, 9);
    for m = 1:9
        for n = 1:9
            if original(m, n) ~= 0
                original01(m, n, original(m, n)) = 1;
            end
        end
    end
    lb = reshape(original01, N, 1);
end
ub = ones(N, 1); 

%% 线性规划求解
x = intlinprog(f,intcon,[],[],Aeq,beq,lb,ub);
x = round(x); % 通常，解 x(intCon) 中一些应为整数值的分量并不是精确的整数。intlinprog 将处在整数容差 IntegerTolerance 内的所有解值视为整数。
solution01 = reshape(x, 9, 9, 9);
solution = zeros(9, 9);
for n = 1:9
    solution = solution + solution01(:, :, n) * n;
end
solution 
toc
