package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("VariableInitialisation")
@desc("Checks if the normal variables are initialised at class level")
class VariableInitialisationCheck extends Check {

	public var severity:String = "ERROR";

	override function actualRun() {
		for (td in _checker.ast.decls) {
			switch (td.decl){
				case EClass(d):
					checkFields(d);
				default:
			}
		}
	}

	function checkFields(d:Definition<ClassFlag, Array<Field>>) {
		for (field in d.data) {
			if (field.name != "new") {
				if (d.flags.indexOf(HInterface) > -1) checkInterfaceField(field);
				else checkField(field);
			}
		}
	}

	function checkInterfaceField(f:Field) {
		var isPrivate = false;
		var isPublic = false;
		var isInline = false;
		var isStatic = false;

		if (f.access.indexOf(AInline) > -1) isInline = true;
		else if (f.access.indexOf(AStatic) > -1) isStatic = true;
		else if (f.access.indexOf(APrivate) > -1) isPrivate = true;
		else isPublic = true;

		_genericCheck(isInline, isPrivate, isPublic, isStatic, f);
	}

	function checkField(f:Field) {
		var isPrivate = false;
		var isPublic = false;
		var isInline = false;
		var isStatic = false;

		if (f.access.indexOf(AInline) > -1) isInline = true;
		else if (f.access.indexOf(AStatic) > -1) isStatic = true;
		else if (f.access.indexOf(APublic) > -1) isPublic = true;
		else isPrivate = true;

		_genericCheck(isInline, isPrivate, isPublic, isStatic, f);
	}

	function _genericCheck(isInline:Bool, isPrivate:Bool, isPublic:Bool, isStatic:Bool, f:Field) {
		if (isPrivate || isPublic) {
			switch (f.kind) {
				case FVar(t, a):
					if (Std.string(f.kind).indexOf("expr =>") > -1) {
						_warnVarinit(f.name, f.pos);
						return;
					}
				case FFun(f):
					return;
				case FProp(g, s, t, a):
					return;
			}
		}
	}

	function _warnVarinit(name:String, pos:Position) {
		logPos('Invalid variable initialisation \"${name}\" (move initialisation to constructor or function)', pos, Reflect.field(SeverityLevel, severity));
	}
}