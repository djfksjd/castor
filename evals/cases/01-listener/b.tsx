// socket.ts exports one app-wide event bus that lives for the whole session.
// The parent renders <ChatPanel key={roomId} roomId={roomId} />, so switching
// rooms remounts this component.
import { useEffect, useState } from "react";
import { bus } from "./socket";

export function ChatPanel({ roomId }: { roomId: string }) {
  const [messages, setMessages] = useState<string[]>([]);

  useEffect(() => {
    const handler = (m: { room: string; text: string }) => {
      if (m.room === roomId) setMessages((prev) => [...prev.slice(-199), m.text]);
    };
    bus.on("message", handler);
    return () => bus.off("message", handler);
  }, [roomId]);

  return <ul>{messages.map((m, i) => <li key={i}>{m}</li>)}</ul>;
}
