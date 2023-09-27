# 32位超前进位加法器

## 实现概览
我们实现的32位超前进位加法器 (CLA) 由2个16位CLA直接串接组成。

而16位CLA的主要组件包括：

- PG generator (PG)：P代表propagate, G代表generate，转化输入的两位数以方便超前进位，本质上是一个半加器。
- PGM generator：可以类比成4位的PG，将每4位P、G抽象为一个单位，输出整体的PM、GM，便于实现多级超前进位。
- 4位Carry Lookahead Unit (CLU) : 超前进位的核心组件，通过展开多层逻辑以及多输入位的与门、或门实现超前进位和并行计算。
- 4位CLA：可类比成4位的没有carry位全加器，内含1个CLU，实现了4位的超前加法。

16位CLA由16个PG、4个PGM、4个CLA和1个额外的CLU组成。各组件具体实现可见源码。

## 为什么超前进位加法器更快？
相比波纹进位加法器，超前进位加法器高性能的核心在于其 **并行性**。

波纹进位加法器由若干全加器串联组成，因而每一位的运算必须依赖前一位的进位，从而导致了与操作数位数成正比的延迟。

而超前进位加法器则对每一位引入了 **P(propagte)** 和 **G(generate)** 的概念，分别代表两个操作数的每一位是否会在**传入进位时传播进位**和**产生进位**，它们的计算不依赖于上一位的进位。而由 $C_{i+1} = G_i +(P_i \cdot C_i)$，我们再进行逻辑运算的逐层展开，使得每一个 $C_i$的表达式中含有的进位只有$C_0$，使得每一位的加法都可以并行计算，从而提高了运算速度。

这样的并行依赖于**多输入位的与门、或门**，否则无法达成并行的效果。但扇入的增大会导致逻辑门底层的实现更为复杂，且可能增加其延迟，所以我们不能无止境地进行超前进位。因而实际应用中常会应用**分块**的方式构建更多位数的加法器。