require_relative 'spec_helper'
require_relative '../denotational'

describe 'the denotational semantics of Simple' do
  describe 'expressions' do
    describe 'a variable' do
      subject { Variable.new(:x) }
      let(:value) { 42 }
      let(:environment) { { x: value } }

      context in: :ruby do
        it { should be_denoted_by '-> e { e[:x] }' }
        it { should mean(value).within(environment) }
      end

      context in: :javascript do
        it { should be_denoted_by 'function (e) { return e["x"]; }' }
        it { should mean(value).within(environment) }
      end

      context in: :clojure do
        it { should be_denoted_by '(fn [e] (e "x"))' }
        it { should mean(value).within(environment) }
      end
    end

    describe 'a number' do
      subject { Number.new(42) }

      context in: :ruby do
        it { should be_denoted_by '-> e { 42 }' }
        it { should mean 42 }
      end

      context in: :javascript do
        it { should be_denoted_by 'function (e) { return 42; }' }
        it { should mean 42 }
      end

      context in: :clojure do
        it { should be_denoted_by '(fn [e] 42)' }
      end
    end

    describe 'booleans' do
      describe 'true' do
        subject { Boolean.new(true) }

        context in: :ruby do
          it { should be_denoted_by '-> e { true }' }
          it { should mean true }
        end

        context in: :javascript do
          it { should be_denoted_by 'function (e) { return true; }' }
          it { should mean true }
        end

        context in: :clojure do
          it { should be_denoted_by '(fn [e] true)' }
        end
      end

      describe 'false' do
        subject { Boolean.new(false) }

        context in: :ruby do
          it { should be_denoted_by '-> e { false }' }
          it { should mean false }
        end

        context in: :javascript do
          it { should be_denoted_by 'function (e) { return false; }' }
          it { should mean false }
        end

        context in: :clojure do
          it { should be_denoted_by '(fn [e] false)' }
        end
      end
    end

    describe 'addition' do
      context 'without reducible subexpressions' do
        subject { Add.new(Number.new(1), Number.new(2)) }

        context in: :ruby do
          it { should be_denoted_by '-> e { (-> e { 1 }).call(e) + (-> e { 2 }).call(e) }' }
          it { should mean 3 }
        end

        context in: :javascript do
          it { should be_denoted_by 'function (e) { return (function (e) { return 1; }(e)) + (function (e) { return 2; }(e)); }' }
          it { should mean 3 }
        end

        context in: :clojure do
          it { should be_denoted_by '(fn [e] (+ ((fn [e] 1) e) ((fn [e] 2) e)))' }
        end
      end

      context 'with a reducible subexpression' do
        context 'on the left' do
          subject { Add.new(Add.new(Number.new(1), Number.new(2)), Number.new(3)) }

          context in: :ruby do
            it { should be_denoted_by '-> e { (-> e { (-> e { 1 }).call(e) + (-> e { 2 }).call(e) }).call(e) + (-> e { 3 }).call(e) }' }
            it { should mean 6 }
          end

          context in: :javascript do
            it { should be_denoted_by 'function (e) { return (function (e) { return (function (e) { return 1; }(e)) + (function (e) { return 2; }(e)); }(e)) + (function (e) { return 3; }(e)); }' }
            it { should mean 6 }
          end

          context in: :clojure do
            it { should be_denoted_by '(fn [e] (+ ((fn [e] (+ ((fn [e] 1) e) ((fn [e] 2) e))) e) ((fn [e] 3) e)))' }
          end
        end

        context 'on the right' do
          subject { Add.new(Number.new(1), Add.new(Number.new(2), Number.new(3))) }

          context in: :ruby do
            it { should be_denoted_by '-> e { (-> e { 1 }).call(e) + (-> e { (-> e { 2 }).call(e) + (-> e { 3 }).call(e) }).call(e) }' }
            it { should mean 6 }
          end

          context in: :javascript do
            it { should be_denoted_by 'function (e) { return (function (e) { return 1; }(e)) + (function (e) { return (function (e) { return 2; }(e)) + (function (e) { return 3; }(e)); }(e)); }' }
            it { should mean 6 }
          end

          context in: :clojure do
            it { should be_denoted_by '(fn [e] (+ ((fn [e] 1) e) ((fn [e] (+ ((fn [e] 2) e) ((fn [e] 3) e))) e)))' }
          end
        end

        context 'on both sides' do
          subject { Add.new(Add.new(Number.new(1), Number.new(2)), Add.new(Number.new(3), Number.new(4))) }

          context in: :ruby do
            it { should be_denoted_by '-> e { (-> e { (-> e { 1 }).call(e) + (-> e { 2 }).call(e) }).call(e) + (-> e { (-> e { 3 }).call(e) + (-> e { 4 }).call(e) }).call(e) }' }
            it { should mean 10 }
          end

          context in: :javascript do
            it { should be_denoted_by 'function (e) { return (function (e) { return (function (e) { return 1; }(e)) + (function (e) { return 2; }(e)); }(e)) + (function (e) { return (function (e) { return 3; }(e)) + (function (e) { return 4; }(e)); }(e)); }' }
            it { should mean 10 }
          end

          context in: :clojure do
            it { should be_denoted_by '(fn [e] (+ ((fn [e] (+ ((fn [e] 1) e) ((fn [e] 2) e))) e) ((fn [e] (+ ((fn [e] 3) e) ((fn [e] 4) e))) e)))' }
          end
        end
      end
    end

    describe 'multiplication' do
      context 'without reducible subexpressions' do
        subject { Multiply.new(Number.new(2), Number.new(3)) }

        context in: :ruby do
          it { should be_denoted_by '-> e { (-> e { 2 }).call(e) * (-> e { 3 }).call(e) }' }
          it { should mean 6 }
        end

        context in: :javascript do
          it { should be_denoted_by 'function (e) { return (function (e) { return 2; }(e)) * (function (e) { return 3; }(e)); }' }
          it { should mean 6 }
        end

        context in: :clojure do
          it { should be_denoted_by '(fn [e] (* ((fn [e] 2) e) ((fn [e] 3) e)))' }
        end
      end

      context 'with a reducible subexpression' do
        context 'on the left' do
          subject { Multiply.new(Multiply.new(Number.new(2), Number.new(3)), Number.new(4)) }

          context in: :ruby do
            it { should be_denoted_by '-> e { (-> e { (-> e { 2 }).call(e) * (-> e { 3 }).call(e) }).call(e) * (-> e { 4 }).call(e) }' }
            it { should mean 24 }
          end

          context in: :javascript do
            it { should be_denoted_by 'function (e) { return (function (e) { return (function (e) { return 2; }(e)) * (function (e) { return 3; }(e)); }(e)) * (function (e) { return 4; }(e)); }' }
            it { should mean 24 }
          end

          context in: :clojure do
            it { should be_denoted_by '(fn [e] (* ((fn [e] (* ((fn [e] 2) e) ((fn [e] 3) e))) e) ((fn [e] 4) e)))' }
          end
        end

        context 'on the right' do
          subject { Multiply.new(Number.new(2), Multiply.new(Number.new(3), Number.new(4))) }

          context in: :ruby do
            it { should be_denoted_by '-> e { (-> e { 2 }).call(e) * (-> e { (-> e { 3 }).call(e) * (-> e { 4 }).call(e) }).call(e) }' }
            it { should mean 24 }
          end

          context in: :javascript do
            it { should be_denoted_by 'function (e) { return (function (e) { return 2; }(e)) * (function (e) { return (function (e) { return 3; }(e)) * (function (e) { return 4; }(e)); }(e)); }' }
            it { should mean 24 }
          end

          context in: :clojure do
            it { should be_denoted_by '(fn [e] (* ((fn [e] 2) e) ((fn [e] (* ((fn [e] 3) e) ((fn [e] 4) e))) e)))' }
          end
        end

        context 'on both sides' do
          subject { Multiply.new(Multiply.new(Number.new(2), Number.new(3)), Multiply.new(Number.new(4), Number.new(5))) }

          context in: :ruby do
            it { should be_denoted_by '-> e { (-> e { (-> e { 2 }).call(e) * (-> e { 3 }).call(e) }).call(e) * (-> e { (-> e { 4 }).call(e) * (-> e { 5 }).call(e) }).call(e) }' }
            it { should mean 120 }
          end

          context in: :javascript do
            it { should be_denoted_by 'function (e) { return (function (e) { return (function (e) { return 2; }(e)) * (function (e) { return 3; }(e)); }(e)) * (function (e) { return (function (e) { return 4; }(e)) * (function (e) { return 5; }(e)); }(e)); }' }
            it { should mean 120 }
          end

          context in: :clojure do
            it { should be_denoted_by '(fn [e] (* ((fn [e] (* ((fn [e] 2) e) ((fn [e] 3) e))) e) ((fn [e] (* ((fn [e] 4) e) ((fn [e] 5) e))) e)))' }
          end
        end
      end
    end

    describe 'less than' do
      context 'without reducible subexpressions' do
        subject { LessThan.new(Number.new(1), Number.new(2)) }

        context in: :ruby do
          it { should be_denoted_by '-> e { (-> e { 1 }).call(e) < (-> e { 2 }).call(e) }' }
          it { should mean true }
        end

        context in: :javascript do
          it { should be_denoted_by 'function (e) { return (function (e) { return 1; }(e)) < (function (e) { return 2; }(e)); }' }
          it { should mean true }
        end

        context in: :clojure do
          it { should be_denoted_by '(fn [e] (< ((fn [e] 1) e) ((fn [e] 2) e)))' }
        end
      end

      context 'with a reducible subexpression' do
        context 'on the left' do
          subject { LessThan.new(Add.new(Number.new(2), Number.new(3)), Number.new(4)) }

          context in: :ruby do
            it { should be_denoted_by '-> e { (-> e { (-> e { 2 }).call(e) + (-> e { 3 }).call(e) }).call(e) < (-> e { 4 }).call(e) }' }
            it { should mean false }
          end

          context in: :javascript do
            it { should be_denoted_by 'function (e) { return (function (e) { return (function (e) { return 2; }(e)) + (function (e) { return 3; }(e)); }(e)) < (function (e) { return 4; }(e)); }' }
            it { should mean false }
          end

          context in: :clojure do
            it { should be_denoted_by '(fn [e] (< ((fn [e] (+ ((fn [e] 2) e) ((fn [e] 3) e))) e) ((fn [e] 4) e)))' }
          end
        end

        context 'on the right' do
          subject { LessThan.new(Number.new(1), Add.new(Number.new(2), Number.new(3))) }

          context in: :ruby do
            it { should be_denoted_by '-> e { (-> e { 1 }).call(e) < (-> e { (-> e { 2 }).call(e) + (-> e { 3 }).call(e) }).call(e) }' }
            it { should mean true }
          end

          context in: :javascript do
            it { should be_denoted_by 'function (e) { return (function (e) { return 1; }(e)) < (function (e) { return (function (e) { return 2; }(e)) + (function (e) { return 3; }(e)); }(e)); }' }
            it { should mean true }
          end

          context in: :clojure do
            it { should be_denoted_by '(fn [e] (< ((fn [e] 1) e) ((fn [e] (+ ((fn [e] 2) e) ((fn [e] 3) e))) e)))' }
          end
        end

        context 'on both sides' do
          subject { LessThan.new(Add.new(Number.new(1), Number.new(5)), Multiply.new(Number.new(2), Number.new(3))) }

          context in: :ruby do
            it { should be_denoted_by '-> e { (-> e { (-> e { 1 }).call(e) + (-> e { 5 }).call(e) }).call(e) < (-> e { (-> e { 2 }).call(e) * (-> e { 3 }).call(e) }).call(e) }' }
            it { should mean false }
          end

          context in: :javascript do
            it { should be_denoted_by 'function (e) { return (function (e) { return (function (e) { return 1; }(e)) + (function (e) { return 5; }(e)); }(e)) < (function (e) { return (function (e) { return 2; }(e)) * (function (e) { return 3; }(e)); }(e)); }' }
            it { should mean false }
          end

          context in: :clojure do
            it { should be_denoted_by '(fn [e] (< ((fn [e] (+ ((fn [e] 1) e) ((fn [e] 5) e))) e) ((fn [e] (* ((fn [e] 2) e) ((fn [e] 3) e))) e)))' }
          end
        end
      end
    end
  end

  describe 'statements' do
    describe 'do-nothing' do
      subject { DoNothing.new }
      let(:environment) { { x: 42 } }

      context in: :ruby do
        it { should be_denoted_by '-> e { e }' }
        it { should mean(environment).within(environment) }
      end

      context in: :javascript do
        it { should be_denoted_by 'function (e) { return e; }' }
        it { should mean(environment).within(environment) }
      end

      context in: :clojure do
        it { should be_denoted_by '(fn [e] e)' }
      end
    end

    describe 'assignment' do
      let(:environment) { { x: 1, y: 2 } }

      context 'without a reducible subexpression' do
        subject { Assign.new(:x, Number.new(5)) }

        context in: :ruby do
          it { should be_denoted_by '-> e { e.merge({ :x => (-> e { 5 }).call(e) }) }' }
          it { should mean(x: 5, y: 2).within(environment) }
        end

        context in: :javascript do
          it { should be_denoted_by 'function (e) { e["x"] = (function (e) { return 5; }(e)); return e; }' }
          it { should mean(x: 5, y: 2).within(environment) }
        end

        context in: :clojure do
          it { should be_denoted_by '(fn [e] (assoc e "x" ((fn [e] 5) e)))' }
        end
      end

      context 'with a reducible subexpression' do
        subject { Assign.new(:x, Add.new(Number.new(2), Number.new(3))) }

        context in: :ruby do
          it { should be_denoted_by '-> e { e.merge({ :x => (-> e { (-> e { 2 }).call(e) + (-> e { 3 }).call(e) }).call(e) }) }' }
          it { should mean(x: 5, y: 2).within(environment) }
        end

        context in: :javascript do
          it { should be_denoted_by 'function (e) { e["x"] = (function (e) { return (function (e) { return 2; }(e)) + (function (e) { return 3; }(e)); }(e)); return e; }' }
          it { should mean(x: 5, y: 2).within(environment) }
        end

        context in: :clojure do
          it { should be_denoted_by '(fn [e] (assoc e "x" ((fn [e] (+ ((fn [e] 2) e) ((fn [e] 3) e))) e)))' }
        end
      end
    end

    describe 'sequence' do
      let(:environment) { { y: 3 } }

      context 'without reducible substatements' do
        subject { Sequence.new(DoNothing.new, DoNothing.new) }

        context in: :ruby do
          it { should be_denoted_by '-> e { (-> e { e }).call((-> e { e }).call(e)) }' }
          it { should mean(environment).within(environment) }
        end

        context in: :javascript do
          it { should be_denoted_by 'function (e) { return (function (e) { return e; }(function (e) { return e; }(e))); }' }
          it { should mean(environment).within(environment) }
        end

        context in: :clojure do
          it { should be_denoted_by '(fn [e] ((fn [e] e) ((fn [e] e) e)))' }
        end
      end

      context 'with a reducible substatement' do
        context 'in first position' do
          subject { Sequence.new(Assign.new(:x, Number.new(1)), DoNothing.new) }

          context in: :ruby do
            it { should be_denoted_by '-> e { (-> e { e }).call((-> e { e.merge({ :x => (-> e { 1 }).call(e) }) }).call(e)) }' }
            it { should mean(x: 1, y: 3).within(environment) }
          end

          context in: :javascript do
            it { should be_denoted_by 'function (e) { return (function (e) { return e; }(function (e) { e["x"] = (function (e) { return 1; }(e)); return e; }(e))); }' }
            it { should mean(x: 1, y: 3).within(environment) }
          end

          context in: :clojure do
            it { should be_denoted_by '(fn [e] ((fn [e] e) ((fn [e] (assoc e "x" ((fn [e] 1) e))) e)))' }
          end
        end

        context 'in second position' do
          subject { Sequence.new(DoNothing.new, Assign.new(:x, Number.new(2))) }

          context in: :ruby do
            it { should be_denoted_by '-> e { (-> e { e.merge({ :x => (-> e { 2 }).call(e) }) }).call((-> e { e }).call(e)) }' }
            it { should mean(x: 2, y: 3).within(environment) }
          end

          context in: :javascript do
            it { should be_denoted_by 'function (e) { return (function (e) { e["x"] = (function (e) { return 2; }(e)); return e; }(function (e) { return e; }(e))); }' }
            it { should mean(x: 2, y: 3).within(environment) }
          end

          context in: :clojure do
            it { should be_denoted_by '(fn [e] ((fn [e] (assoc e "x" ((fn [e] 2) e))) ((fn [e] e) e)))' }
          end
        end

        context 'in both positions' do
          subject { Sequence.new(Assign.new(:x, Number.new(1)), Assign.new(:x, Number.new(2))) }

          context in: :ruby do
            it { should be_denoted_by '-> e { (-> e { e.merge({ :x => (-> e { 2 }).call(e) }) }).call((-> e { e.merge({ :x => (-> e { 1 }).call(e) }) }).call(e)) }' }
            it { should mean(x: 2, y: 3).within(environment) }
          end

          context in: :javascript do
            it { should be_denoted_by 'function (e) { return (function (e) { e["x"] = (function (e) { return 2; }(e)); return e; }(function (e) { e["x"] = (function (e) { return 1; }(e)); return e; }(e))); }' }
            it { should mean(x: 2, y: 3).within(environment) }
          end

          context in: :clojure do
            it { should be_denoted_by '(fn [e] ((fn [e] (assoc e "x" ((fn [e] 2) e))) ((fn [e] (assoc e "x" ((fn [e] 1) e))) e)))' }
          end
        end
      end
    end

    describe 'if' do
      let(:environment) { { x: 1, y: 2 } }

      context 'without a reducible subexpression' do
        subject { If.new(Boolean.new(false), Assign.new(:x, Number.new(3)), Assign.new(:y, Number.new(3))) }

        context in: :ruby do
          it { should be_denoted_by '-> e { if (-> e { false }).call(e) then (-> e { e.merge({ :x => (-> e { 3 }).call(e) }) }).call(e) else (-> e { e.merge({ :y => (-> e { 3 }).call(e) }) }).call(e) end }' }
          it { should mean(x: 1, y: 3).within(environment) }
        end

        context in: :javascript do
          it { should be_denoted_by 'function (e) { if (function (e) { return false; }(e)) { return (function (e) { e["x"] = (function (e) { return 3; }(e)); return e; }(e)); } else { return (function (e) { e["y"] = (function (e) { return 3; }(e)); return e; }(e)); } }' }
          it { should mean(x: 1, y: 3).within(environment) }
        end

        context in: :clojure do
          it { should be_denoted_by '(fn [e] (if ((fn [e] false) e) ((fn [e] (assoc e "x" ((fn [e] 3) e))) e) ((fn [e] (assoc e "y" ((fn [e] 3) e))) e)))' }
        end
      end

      context 'with a reducible subexpression' do
        subject { If.new(LessThan.new(Number.new(3), Number.new(4)), Assign.new(:x, Number.new(3)), Assign.new(:y, Number.new(3))) }

        context in: :ruby do
          it { should be_denoted_by '-> e { if (-> e { (-> e { 3 }).call(e) < (-> e { 4 }).call(e) }).call(e) then (-> e { e.merge({ :x => (-> e { 3 }).call(e) }) }).call(e) else (-> e { e.merge({ :y => (-> e { 3 }).call(e) }) }).call(e) end }' }
          it { should mean(x: 3, y: 2).within(environment) }
        end

        context in: :javascript do
          it { should be_denoted_by 'function (e) { if (function (e) { return (function (e) { return 3; }(e)) < (function (e) { return 4; }(e)); }(e)) { return (function (e) { e["x"] = (function (e) { return 3; }(e)); return e; }(e)); } else { return (function (e) { e["y"] = (function (e) { return 3; }(e)); return e; }(e)); } }' }
          it { should mean(x: 3, y: 2).within(environment) }
        end

        context in: :clojure do
          it { should be_denoted_by '(fn [e] (if ((fn [e] (< ((fn [e] 3) e) ((fn [e] 4) e))) e) ((fn [e] (assoc e "x" ((fn [e] 3) e))) e) ((fn [e] (assoc e "y" ((fn [e] 3) e))) e)))' }
        end
      end
    end

    describe 'while' do
      subject { While.new(LessThan.new(Variable.new(:x), Number.new(5)), Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))) }
      let(:environment) { { x: 1 } }

      context in: :ruby do
        it { should be_denoted_by '-> e { while (-> e { (-> e { e[:x] }).call(e) < (-> e { 5 }).call(e) }).call(e); e = (-> e { e.merge({ :x => (-> e { (-> e { e[:x] }).call(e) * (-> e { 3 }).call(e) }).call(e) }) }).call(e); end; e }'}
        it { should mean(x: 9).within(environment) }
      end

      context in: :javascript do
        it { should be_denoted_by 'function (e) { while (function (e) { return (function (e) { return e["x"]; }(e)) < (function (e) { return 5; }(e)); }(e)) { e = (function (e) { e["x"] = (function (e) { return (function (e) { return e["x"]; }(e)) * (function (e) { return 3; }(e)); }(e)); return e; }(e)); } return e; }' }
        it { should mean(x: 9).within(environment) }
      end

      context in: :clojure do
        it { should be_denoted_by '(fn [e] (if ((fn [e] (< ((fn [e] (e "x")) e) ((fn [e] 5) e))) e) (recur ((fn [e] (assoc e "x" ((fn [e] (* ((fn [e] (e "x")) e) ((fn [e] 3) e))) e))) e)) e))' }
      end
    end
  end
end
