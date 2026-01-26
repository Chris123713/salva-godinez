

const Button = ({
  label,
  onClick,
  disableArrow,
  theme,
  fontSizeText,
  height,
  fontSize,
  disabled,
  className,
  style,
}: {
  label: string;
  onClick: () => void;
  disableArrow?: boolean;
  theme?: "green" | "red";
  fontSizeText?: string;
  height?: string;
  fontSize?: string;
  disabled?: boolean;
  className?: string;
  style?: React.CSSProperties;
}) => {
  return (
    <div
      className={`joy overflow-hidden ${disabled ? "opacity-50 disabled cursor-not-allowed" : ""} ${
        theme === "red" ? "create-btn-red" : "create-btn"
      } ${className}`}
      onClick={onClick}
      style={{
        height: height,
        fontSize: fontSize,
        ...style,
      }}
    >
      <p className={`mx-auto ${fontSizeText}`} style={{
        textShadow: "0px 0px 46.3px #1FEEB0",
      }}>{label}</p>
    </div>
  );
};

export default Button;